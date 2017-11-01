
---------
-- used in access_by_lua_block directive
--
-- auto-cache 主要实现
--
-- 这个 filter 需要 auto-cache-response-header-handler 和 auto-cache-maker 的配合
---------
local lz4 = require("lz4.lz4")
local decompress = lz4.decompress
local json_decode = JSON.decode

local function _decompressJSONStr(compressedStr)
  local origStr = decompress(compressedStr)
  -- utils.log('decompressed len:' .. string.len(origStr))
  return origStr
end

local function _determineCache(ngx)
  -- 因为 auto-cache-trigger 在上一次请求时把类型值放在了 Last-Modified 中，所以从 If-Modified-Since 取
  local cacheType = ngx.req.get_headers()['If-Modified-Since']
  -- utils.log(cacheType)
  return __yqj_global_cache[cacheType]
end

local function _isCacheHit(uri, cacheToUse)
  -- 没有 cache 可用
  if not cacheToUse then
    -- utils.log('[auto-cache] No cache found, can not use auto-cache')
    return false
  end
  
  local ttl, err = cacheToUse:peek(uri)
  
  if err then
    utils.elog('[auto-cache] Error peek cache value with uri:', uri)
    return false
  end
  
  if ttl then
    -- utils.log('[auto-cache] Found cache ' + cacheToUse.name)
    return true
  end
  
  return false
end

local function _cacheRefresher()
  return nil -- return false to indicate the cache missing...
end

local function _getCachedValue(uri, cacheToUse)
  -- this call will respectively hit L1 and L2 before running the
  -- callback (L3). The returned value will then be stored in L2 and
  -- L1 for the next request.
  
  local cachedJsonStr, err = cacheToUse:get(uri, nil, _cacheRefresher)
  if err then
    utils.elog('err reading cache value with uri:', uri)
    cachedJsonStr = nil -- 出错当是没有缓存
  end
  
  -- local res = ngx.location.capture(uri, { share_all_vars = true })
  -- local freshJsonStr = res.body
  -- utils.log(freshJsonStr)
  
  return (cachedJsonStr)
end

local function _sendCachedHeaders(ngx, origHeaders)
  _.each(origHeaders, function(k, v)
      ngx.header[k] = v
  end)
end

local function _sendCachedResponse(ngx, origResp)
  ngx.say(origResp)
end

local function _sendCachedDataToClient(ngx, compressedCacheData)
  local cachedData = _decompressJSONStr(compressedCacheData)
  
  -- cachedData format: see auto-cache-maker
  local tmp = cachedData:split('__a_c_h__')
  
  local origHeaders = json_decode(tmp[1])
  local origResp = tmp[2]
  
  _sendCachedHeaders(ngx, origHeaders)
  _sendCachedResponse(ngx, origResp)
  ngx.exit(ngx.HTTP_OK) -- 终止请求，不转发到 backend，见 nginx.conf
end

-- export

local M = {}

function M.applyAutoCache(ngx)
  local cacheToUse = _determineCache(ngx)
  local uri = ngx.var.uri
  
  -- 下面注意: _isCacheHit() 用的 peek(), 而 _getCachedValue() 用的 get()
  
  if not _isCacheHit(uri, cacheToUse) then
    utils.log('[auto-cache] missing for uri: ' .. uri .. ', pass req to backend server')
    return -- pass request to backend server
  end
  
  local cachedJsonStr = _getCachedValue(uri, cacheToUse)
  
  -- peek() 和 get() 有时间差，peek() 查到并不保证 get() 一定有(peek时有 -> 过期 -> get -> nil)
  if not cachedJsonStr then -- 所以再检查一次
    utils.log('[auto-cache] missing for uri: ' .. uri .. ', pass req to backend server')
    return -- pass request to backend server
  end
  
  utils.log('[auto-cache] (' + cacheToUse.name + ') hit for uri: ' + uri)
  
  _sendCachedDataToClient(ngx, cachedJsonStr)
end


return M

