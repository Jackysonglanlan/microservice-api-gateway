
---------
-- used in body_filter_by_lua_block directive
---------

local function _isNeedToTriggerAutoCache(requestCacheConf)
  return type(requestCacheConf) == 'table' -- see auto-cache-response-header-handler.lua
end

-- this only runs *once* until the key expires, so do expansive operations like connecting to a
-- remote backend here.
-- i.e: call a backend server or redis in this callback
local function _cacheRefresher()
  -- utils.log('[auto-cache-maker] Pack response data and orig headers')
  
  -- 只是标记一下即可, 凡是有这个标记的，都会被响应 304
  return true
end

local function _determineCacheType(requestCacheConf)
  return __yqj_global_cache.cache[requestCacheConf.type] -- see lua/src/init/auto-cache.lua
end

local function _cacheURIToMLCache(requestCacheConf, ngx)
  local requestedCache = _determineCacheType(requestCacheConf)
  
  -- utils.log('[auto-cache-maker] Ready to cache response header and data, using cache: ' + requestedCache.name)
  
  local uri = ngx.var.uri
  
  -- 缓存结构: 请求 uri -> true
  -- 这里注意，是通过 get 来设置缓存值的，why？
  -- 见 https://github.com/thibaultcha/lua-resty-mlcache 的 set() 方法说明
  requestedCache:get(uri, nil, _cacheRefresher)
end

local function _cleanupCTX(ngx)
  ngx.ctx.requestCacheConf = nil
end

-- main process

local M = {}

function M.makeCache(ngx)
  local ctx = ngx.ctx
  
  -- 这个值是通过 auto-cache-response-header-handler 设置，然后流到这里的
  local backendRequestCacheConf = ctx.requestCacheConf
  
  -- utils.log(ctx)
  -- utils.log(backendRequestCacheConf)
  
  if not _isNeedToTriggerAutoCache(backendRequestCacheConf) then
    -- no need to trigger cache, pass
    -- 注意：这里 pass 了，在 auto-cache.lua 那里，就不能从 cache 中读了，相当于没有 cache，所有请求都要被转发到 backend
    -- 也就实现了 不缓存
    return
  end
  
  -- 写入 ML 缓存，等下一次请求上来，auto-cache.lua 那边就可以直接取了
  _cacheURIToMLCache(backendRequestCacheConf, ngx)
  
  _cleanupCTX(ngx)
end

return M


