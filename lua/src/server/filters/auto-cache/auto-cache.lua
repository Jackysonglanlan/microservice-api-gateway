
---------
-- used in access_by_lua_block directive
--
-- auto-cache 主要实现
--
-- 这个 filter 需要 auto-cache-response-header-handler 和 auto-cache-maker 的配合
---------

local function _getCacheTypeFromReqHeader(ngx)
  -- cacheType 是个时间戳, 代表缓存类型，见 init.auto-cache
  local cacheType = ngx.req.get_headers()['If-Modified-Since']
  -- utils.log(cacheType)
  return cacheType
end

local function _determineCache(ngx)
  return __yqj_global_cache.cache[_getCacheTypeFromReqHeader(ngx)]
end

local function _isCacheHit(uri, cacheToUse)
  -- 没有 cache 可用
  if not cacheToUse then
    utils.wlog('[auto-cache] No cache found, can not use auto-cache')
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
  -- 这里只取，不生成缓存值，所以直接返回 nil
  return nil
end

local function _getCachedValue(uri, cacheToUse)
  -- this call will respectively hit L1 and L2 before running the
  -- callback (L3). The returned value will then be stored in L2 and
  -- L1 for the next request.
  
  local cachedData, err = cacheToUse:get(uri, nil, _cacheRefresher)
  if err then
    utils.elog('err reading cache value with uri:', uri, err)
    cachedData = nil -- 出错当是没有缓存
  end
  
  return (cachedData)
end

local function _sendCachedHeaders(ngx)
  -- 这里注意，由于这里的 cacheType 和 If-Modified-Since 是一样的，根据 http 规范: 这种情况代表缓存命中
  local cacheType = _getCacheTypeFromReqHeader(ngx)
  
  -- 响应的时候带上缓存类型(UTC 时间戳)，下次再请求的时候，才找得到
  ngx.header['Last-Modified'] = cacheType
end

local function _sendCachedDataToClient(ngx)
  _sendCachedHeaders(ngx)
  -- 这里，没有 response body，因为我们要用 304，所以没有 _sendCachedBody()
  
  -- 这里，用 HTTP_OK(200) 即可，nginx 在真正输出响应的时候会发现: 响应的 Last-Modified 和 请求的 If-Modified-Since 一样,
  -- 然后 nginx 会自动把 status code 改成 304
  
  ngx.exit(ngx.HTTP_OK) -- exit(): 终止请求，不转发到 backend，见 nginx.conf
end

-- export

local M = {}

function M.applyAutoCache(ngx)
  local cacheToUse = _determineCache(ngx)
  local uri = ngx.var.request_uri
  
  -- 下面注意: _isCacheHit() 用的 peek(), 而 _getCachedValue() 用的 get()
  
  if not _isCacheHit(uri, cacheToUse) then
    -- utils.log('[auto-cache] missing for uri: ' .. uri .. ', pass req to backend server')
    return -- pass request to backend server
  end
  
  local cachedData = _getCachedValue(uri, cacheToUse)
  
  -- peek() 和 get() 有时间差，peek() 查到并不保证 get() 一定有(peek时有 -> 过期 -> get -> nil)
  if not cachedData then -- 所以再检查一次
    -- utils.log('[auto-cache] missing between peek() and get() for uri: ' .. uri .. ', pass req to backend server')
    return -- pass request to backend server
  end
  
  -- utils.log('[auto-cache] (' + cacheToUse.name + ') hit for uri: ' + uri)
  
  _sendCachedDataToClient(ngx)
end


return M

