

local utils = require('yqj.utils')(ngx)
local resty_md5 = require "resty.md5"
local string = require "resty.string"
local cjson = require("cjson")

local SIGN_HEADER_KEY = 'sign'
-- todo: set the proper response code for ilegal sign
local ERROR_RESPONSE_DATA = {code=620, error='wrong sign'}

local ERROR_RESPONSE = cjson.encode(ERROR_RESPONSE_DATA)


--[[ 读取 nginx 变量时 要特别注意
CAUTION When reading from an Nginx variable, Nginx will allocate memory in the per-request memory pool which is
freed only at request termination. So when you need to read from an Nginx variable repeatedly in your Lua code,
cache the Nginx variable value to your own Lua variable, for example:
  local val = ngx.var.some_var
  --- use the val repeatedly later
--]]

-- ------- private

function _genePresignStrFromParamsAndHeaders( presignParamTable )
  local a = {}
  for n in pairs(presignParamTable) do table.insert(a, n) end
  table.sort(a)

  local sorted = {}
  for k,sortedKey in pairs(a) do
    if sortedKey ~= SIGN_HEADER_KEY then
      table.insert(sorted, sortedKey..'='..presignParamTable[sortedKey])
    end
  end
  local sortedStr = table.concat(sorted,'&')
  return sortedStr
end

function _escapeStr( presignStr )
  return ngx.escape_uri(presignStr)
end

-- sign with md5
function _sign( presignStr )
  local md5 = resty_md5:new()

  local ok = md5:update(presignStr)
  if not ok then
    return
  end

  local md5 = string.to_hex(md5:final())
  return md5
end

function _calcSign()
  -- get args
  local args = ngx.req.get_uri_args()
  -- utils.debug(args)

  -- get headers
  local headers = ngx.req.get_headers()
  -- utils.debug(headers)

  -- merge
  local allParams = utils.tableMerge(args, headers)
  -- utils.debug(allParams)

  -- gene presignStr
  local presignStr = _genePresignStrFromParamsAndHeaders(headers)
  presignStr = _escapeStr(presignStr)
  -- utils.debug('presignStr', presignStr)

  -- sign
  local md5 = _sign(presignStr)
  return md5
end

function _blockIllegalAccess()
  ngx.log(ngx.ALERT, '[Wrong Sign Reqest] headers: ' .. ngx.req.raw_header())

  ngx.header["Content-Type"] = "application/json"
  ngx.say(ERROR_RESPONSE)
  ngx.eof()
end


---------- main

function checkAPISign()
  local calculatedSign = _calcSign()

  -- local signInHeader = ngx.req.get_headers()[SIGN_HEADER_KEY]
  -- if signInHeader == calculatedSign then
  --   -- sign check ok, pass to backend servers
  --   return
  -- end

  -- [TEST ONLY] read 'sign=111' in url query param to pass the check
  local signInHeader = ngx.req.get_uri_args()[SIGN_HEADER_KEY]
  if signInHeader == '111' then
    -- sign check ok, pass to backend servers
    return
  end

  _blockIllegalAccess()
end

checkAPISign()





