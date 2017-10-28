
local utils = require('yqj.utils')(ngx)
local resty_md5 = require "resty.md5"
local string = require "resty.string"
local merge = require('pl.tablex').merge
local cjson = require("cjson")

local SIGN_HEADER_KEY = 'sign'
-- todo: set the proper response code for ilegal sign
local ERROR_RESPONSE = cjson.encode({code = 620, error = 'wrong sign'})


--[[ 读取 nginx 变量时 要特别注意
CAUTION When reading from an Nginx variable, Nginx will allocate memory in the per-request memory pool which is
freed only at request termination. So when you need to read from an Nginx variable repeatedly in your Lua code,
cache the Nginx variable value to your own Lua variable, for example:
  local val = ngx.var.some_var
  --- use the val repeatedly later
--]]

-- ------- private

local function _genePresignStrFromParamsAndHeaders( presignParamTable )
  local a = {}
  for n in pairs(presignParamTable) do
    table.insert(a, n)
  end
  
  table.sort(a)
  
  local sorted = {}
  for k, sortedKey in pairs(a) do
    if sortedKey ~= SIGN_HEADER_KEY then
      table.insert(sorted, sortedKey .. '=' .. presignParamTable[sortedKey])
    end
  end
  local sortedStr = table.concat(sorted, '&')
  return sortedStr
end

local function _escapeStr( presignStr )
  return ngx.escape_uri(presignStr)
end

-- sign with md5
local function _signStr( presignStr )
  local md5 = resty_md5:new()
  
  local ok = md5:update(presignStr)
  if not ok then
    return
  end
  
  local md5 = string.to_hex(md5:final())
  return md5
end

local function _calcSign()
  -- get args
  local args = ngx.req.get_uri_args()
  -- utils.debug(args)
  
  -- get headers
  local headers = ngx.req.get_headers(50, true) -- must use raw header, so the 2nd param is true
  -- utils.log(headers)
  
  -- merge
  local allParams = merge(args, headers, true)
  -- utils.log(allParams)
  
  -- gene presignStr
  local presignStr = _genePresignStrFromParamsAndHeaders(allParams)
  presignStr = _escapeStr(presignStr)
  -- utils.log('presignStr', presignStr)
  
  -- sign
  local md5 = _signStr(presignStr)
  return md5
end

local function _blockIllegalAccess()
  utils.alog('[Wrong Sign Reqest] headers: ' .. ngx.req.raw_header())
  
  ngx.header["Content-Type"] = "application/json"
  ngx.say(ERROR_RESPONSE)
  ngx.eof()
end


---------- main

--[[

签名算法:
  1. 拿到本次请求的 query 请求参数(不要 form 形式的参数)
  2. 拿到本次请求的 header(如果有 'sign' 头，过滤掉)
  3. 合并请求参数 Entry 和 header Entry
  4. Entry.key 按 字符串alphabeta规则 排序(a ~ z，a 排前面)
  5. 拼接 Entry 的 key 和 value: k1=v1&k2=v2&...，形成 待签名字符串
  6. 对 待签名字符串 做一次 URLEncode
  7. 对 encode 后的字符串做 md5 运算
  8. 把算出的 md5 值放在名称为 'sign' 的请求头中
  9. 发送请求

示例:

  有如下 HTTP 请求:
    GET /api/foo/bar?aaa=111&bbb=222&ccc=333

  带有如下请求头:
    Host: h1
    User-Agent: h2
    xxx: h3
    yyy: h4
    sign:nnnnnnnn

  则这次请求的 待签名字符串 为:
    aaa=111&bbb=222&ccc=333&Host=h1&User-Agent=h2&xxx=h3&yyy=h4

  URLEncode 后:
    aaa%3D111%26bbb%3D222%26ccc%3D333%26Host%3Dh1%26User-Agent%3Dh2%26xxx%3Dh3%26yyy%3Dh4

  md5 计算结果为:
    a665715e30b65981f87a9a3213f27ef6

--]]

local function checkAPISign()
  local calculatedSign = _calcSign()
  utils.log('ilegal sign: ' .. calculatedSign)
  -- local signInHeader = ngx.req.get_headers()[SIGN_HEADER_KEY]
  -- if signInHeader == calculatedSign then
  --   -- sign check ok, pass to backend servers
  --   return
  -- end
  
  -- [TEST ONLY] read 'sign=111' in url query param to pass the check
  local signInHeader = ngx.req.get_uri_args()[SIGN_HEADER_KEY]
  if signInHeader == '111' then
    return
  end
  
  _blockIllegalAccess()
end

checkAPISign()











