
---------
-- used in body_filter_by_lua_xxx directive
-- 注意: 如果缓存已经存在，请求是到不了这个 filter 的，在 auto-cache 那里就会被拦截
---------

local filterUtils = require('lua.src.server.filters.utils')

-- 没有收完数据时，fullRespData 一直为 nil
local fullRespData = filterUtils.bodyFilterGetFullRespData()
if not fullRespData then
  return
end

-- TODO:
-- compress before cache

local function _compressJSONStr(jsonStr)
  -- utils.log(jsonStr)
  return jsonStr
end

local function _isNeedToTriggerAutoCache(ctx)
  return ctx.__autoCache.enabled -- see auto-cache-before-trigger.lua
end

local function _cacheRefresher(respData)
  -- this only runs *once* until the key expires, so
  -- do expansive operations like connecting to a remote
  -- backend here. i.e: call a backend server or redis in this callback
  
  -- 这里，因为已经拿到了数据，所以就直接返回了，不需要查了
  
  -- 返回 压缩后的 响应数据，这个数据会在 auto-cache 中被读出，解压，再返回给客户端
  return _compressJSONStr(respData)
end

local function _addResponseDataToMLCache(uri, ctx, respData)
  -- 通过 get 来设置缓存值，why？见 https://github.com/thibaultcha/lua-resty-mlcache 的 set() 方法说明
  cache:get(uri, nil, _cacheRefresher, respData)
end

local function _cleanupCTX(ctx)
  ctx.__autoCache = nil
end

-- main process

local function _triggerAutoCacheIfDetectedFlag()
  local ctx = ngx.ctx
  
  -- utils.log(fullRespData)
  -- utils.log(ctx)
  
  if not _isNeedToTriggerAutoCache(ctx) then
    -- no need to trigger cache, pass
    -- 注意：这里 pass 了，在 auto-cache 那里，就没有 cache 了，于是，所有请求都要被转发到 backend
    return
  end
  
  local uri = ngx.var.uri
  
  -- 这里，因为已经拿到了数据，所以可以提前写入缓存，等下一次请求上来，auto-cache 就可以直接取了
  _addResponseDataToMLCache(uri, ctx, fullRespData)
  
  _cleanupCTX(ctx)
end

_triggerAutoCacheIfDetectedFlag()
