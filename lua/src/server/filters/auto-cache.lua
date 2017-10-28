
---------
-- used in rewrite_by_lua_file_xxx directive
--
-- auto-cache 主要实现
--
-- 这个 filter 需要 auto-cache-before-trigger 和 auto-cache-trigger 的配合
---------

local function _decompressJSONStr(compressedStr)
  -- utils.log(compressedStr)
  -- TODO
  return compressedStr
end

local function _isCacheHit(uri)
  local ttl, err, value = cache:peek(uri)
  if err then
    utils.wlog('err peek cache value with uri:', uri)
    return false
  end
  
  if ttl then
    return true
  end
  
  return false
  
  -- TEST-ONLY
  -- return true
end

local function _cacheRefresher()
  return nil -- return false to indicate the cache missing...
end

local function _getCachedValue(uri)
  -- this call will respectively hit L1 and L2 before running the
  -- callback (L3). The returned value will then be stored in L2 and
  -- L1 for the next request.
  
  local cachedJsonStr, err = cache:get(uri, nil, _cacheRefresher)
  if err then
    utils.elog('err reading cache value with uri:', uri)
    cachedJsonStr = nil
  end
  
  -- local res = ngx.location.capture(uri, { share_all_vars = true })
  -- local freshJsonStr = res.body
  -- utils.log(freshJsonStr)
  
  return (cachedJsonStr)
end

-- main process

local function _applyAutoCache()
  local uri = ngx.var.uri
  
  if not _isCacheHit(uri) then
    utils.log('auto-cache missing for uri: ' .. uri .. ', pass req to backend server')
    return -- pass request to backend server
  end
  
  local cachedJsonStr = _getCachedValue(uri)
  if not cachedJsonStr then
    utils.log('auto-cache missing for uri: ' .. uri .. ', pass req to backend server')
    return -- pass request to backend server
  end
  
  utils.log('auto-cache hit for uri: ' .. uri)
  ngx.say(_decompressJSONStr(cachedJsonStr))
  ngx.eof()
end

_applyAutoCache()


