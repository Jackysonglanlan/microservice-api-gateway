--------
-- used in access_by_lua_block directive
--
-- auto-cache 主要实现
--
-- 这个 filter 需要 auto-cache-trigger 和 auto-cache-maker 的配合
---------

local lz4 = require("lz4.lz4")
local decompress = lz4.decompress
local json_decode = JSON.decode
local match = string.match

local function _decompressJSONStr(compressedStr)
  local origStr = decompress(compressedStr)
  -- utils.log('decompressed len:' .. string.len(origStr))
  return origStr
end

local function _getCacheTypeFromReqHeader(ngx)
  -- cacheType 是个时间戳, 代表缓存类型，见 init.auto-cache
  local cacheType = ngx.req.get_headers()['If-Modified-Since']
  -- utils.log(cacheType)
  return cacheType
end

local function _determineCache(cacheType)
  local cacheToUse = __yqj_global_cache.cache[cacheType]
  
  if not cacheToUse then
    -- 至少都有 default
    cacheToUse = __yqj_global_cache.cache[__yqj_global_cache.type.default]
  end
  
  return cacheToUse
end

local function _maybeInCache(key, cacheToUse)
  local ttl, err = cacheToUse:peek(key)
  
  if err then
    utils.elog('[auto-cache] Error peek cache value with key:', key)
    return false
  end
  
  if ttl then
    -- utils.log('[auto-cache] Found data in cache ' + cacheToUse.name)
    return true
  end
  
  return false
end

local function _cacheRefresher()
  -- 这里只取，不生成缓存值，所以直接返回 nil
  return nil
end

local function _getCachedValue(key, cacheToUse)
  -- this call will respectively hit L1 and L2 before running the
  -- callback (L3). The returned value will then be stored in L2 and
  -- L1 for the next request.
  
  local cachedData, err = cacheToUse:get(key, nil, _cacheRefresher)
  if err then
    utils.elog('err reading cache value with key:', key, err)
    cachedData = nil -- 出错当是没有缓存
  end
  
  return (cachedData)
end

local function _resp304ToClient(ngx, cacheType)
  -- 响应的时候带上缓存类型(UTC 时间戳)，下次再请求的时候，才找得到
  -- 这里注意，由于这里的 cacheType 和 本次请求的 If-Modified-Since 是一样的，即:
  -- Last-Modified 和 If-Modified-Since 相同, 根据 http 规范: 这种情况代表缓存命中
  ngx.header['Last-Modified'] = cacheType
  
  -- 这里，没有 response body，因为我们要用 304，所以没有 _sendCachedBody()
  
  -- WARN: 用 HTTP_OK(200) 即可，nginx 在真正输出响应的时候会发现: 响应的 Last-Modified 和 请求的 If-Modified-Since 一样,
  -- 然后 nginx 会自动把 status code 改成 304
  
  ngx.exit(ngx.HTTP_OK) -- exit(): 终止请求，不转发到 backend，见 nginx.conf
end

local function _sendCachedHeaders(ngx, origHeaders)
  _.forEach(origHeaders, function(v, k)
    ngx.header[k] = v
  end)
end

local function _sendCachedResponse(ngx, origResp)
  ngx.say(origResp)
end

local function _sendCachedDataToClient(ngx, compressedCacheData)
  local cachedData = _decompressJSONStr(compressedCacheData)
  
  -- cachedData format: see auto-cache-maker
  local tmp = cachedData:split('__6ef30a91b546ada6c5cjs4dbe402deccd80c5dd0f0__')
  
  local origHeaders = json_decode(tmp[1])
  local origResp = tmp[2]
  
  _sendCachedHeaders(ngx, origHeaders)
  _sendCachedResponse(ngx, origResp)
  ngx.exit(ngx.HTTP_OK) -- 终止请求，不转发到 backend，见 nginx.conf
end

-- export

local M = {}

function M.enableAutoCache(ngx)
  local cacheType = _getCacheTypeFromReqHeader(ngx)
  local cacheToUse = _determineCache(cacheType)
  local uri = ngx.var.request_uri
  local cacheKey = ngx.md5(uri)
  
  -- 下面注意: _maybeInCache() 用的 peek(), 而 _getCachedValue() 用的 get()
  if not _maybeInCache(cacheKey, cacheToUse) then
    -- utils.log('[auto-cache] missing for uri: ' .. uri .. ', pass req to backend server')
    return -- pass request to backend server
  end
  
  local cachedData = _getCachedValue(cacheKey, cacheToUse)
  
  -- peek() 和 get() 有时间差，peek() 查到并不保证 get() 一定有(peek时有 -> 过期 -> get -> nil)
  if not cachedData then -- 所以再检查一次
    -- utils.log('[auto-cache] missing between peek() and get() for uri: ' .. uri .. ', pass req to backend server')
    return -- pass request to backend server
  end
  
  -- 缓存命中
  -- utils.log('[auto-cache] Hit cache: ' + cacheToUse.name + ' for uri: ' + uri)
  
  -- 这里 cacheType 可能为 nil，代表客户端不支持 Last-Modified 机制
  local isClientWantUseCache = cacheType and match(cacheType, 'Wed, 01 Jan 3000')
  if isClientWantUseCache then
    -- utils.log('[auto-cache] response 304 to uri: ' + uri)
    -- 直接响应 304 (用 304 可以最大限度节省带宽，因为只需要发送 response header)
    cachedData = nil
    return _resp304ToClient(ngx, cacheType)
  end
  
  -- 如果不支持, 则发送缓存数据(header body 都发送)
  -- utils.log('[auto-cache] client has NO Last-Modified support, send cached data to uri: ' + uri)
  return _sendCachedDataToClient(ngx, cachedData)
end

return M
