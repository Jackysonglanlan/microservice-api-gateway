
---------
-- used in body_filter_by_lua_block directive
---------

local concat = table.concat
local filterUtils = require('server.filters.utils')
local bodyFilterGetFullRespData = filterUtils.bodyFilterGetFullRespData

local lz4 = require("lz4.lz4")
local compress = lz4.compress
local json_encode = JSON.encode

local AUTO_CACHE_TYPE = require('init.auto-cache').type




local function _isNeedToTriggerAutoCache(requestCacheConf)
  return type(requestCacheConf) == 'table' -- see auto-cache-response-header-handler.lua
end

local function _compressJSONStr(jsonStr)
  -- lz4 压缩，保证效率不受影响
  local compressed = compress(jsonStr)
  -- utils.log('compressed len:' + string.len(compressed))
  return compressed
end

-- this only runs *once* until the key expires, so do expansive operations like connecting to a
-- remote backend here.
-- i.e: call a backend server or redis in this callback
local function _defaultCacheRefresher(ngx, respData)
  local respHeaders = ngx.resp.get_headers(50, true)
  -- 所有的 响应 都是在 nginx 层被压缩的，所以这里不能缓存 Content-Encoding，不然要出错
  respHeaders['Content-Encoding'] = nil
  utils.log(respHeaders)
  
  -- 缓存 响应数据 和 header，这样可以使客户端完全透明(客户端完全区分不出来到底是 缓存数据 还是 来自 backend 的数据)
  -- 把 响应数据 和 header 存在一起, 形成最终的缓存数据, auto-cache 那里会把这个数据拆开
  
  -- 由于 respData 可能很大，所以用 concat 完成字符串拼接
  local cachedData = {json_encode(respHeaders) , '__6ef30a91b546ada6c5cjs4dbe402deccd80c5dd0f0__' , respData }
  cachedData = concat(cachedData)
  -- utils.log(cachedData)
  
  -- utils.log('[auto-cache-maker] Compress then cache...')
  
  -- 压缩后再缓存，这个数据会在 auto-cache.lua 中被读出，解压, 拆开 响应数据 和 header，再返回给客户端
  return _compressJSONStr(cachedData)
end

local function _determineCache(requestCacheConf)
  local cacheToUse = __yqj_global_cache.cache[requestCacheConf.type] -- see lua/src/init/auto-cache.lua
  if not cacheToUse then
    cacheToUse = __yqj_global_cache.cache[__yqj_global_cache.type.default]
  end
  return cacheToUse
end

local function _cacheURIToMLCache(requestCacheConf, ngx, respData)
  local requestedCache = _determineCache(requestCacheConf)
  -- utils.log('[auto-cache-maker] Ready to cache response header and data, using cache: ' + requestedCache.name)
  
  local uri = ngx.var.request_uri
  
  -- 缓存结构: 请求 uri -> ${JSON respHeaders}__a_c_h__${response_data}
  -- 这里注意，是通过 get 来设置缓存值的，why？
  -- 见 https://github.com/thibaultcha/lua-resty-mlcache 的 set() 方法说明
  requestedCache:get(uri, nil, _defaultCacheRefresher, ngx, respData)
end

local function _cleanupCTX(ngx)
  ngx.ctx.requestCacheConf = nil
end

-- main process

local M = {}

function M.makeCache(ngx)
  -- non-blocking: 没有收完数据时，这个 filter 会被一直调用, 期间 respData 会一直为 nil
  local respData = bodyFilterGetFullRespData(ngx)
  if not respData then
    return -- 没收完，一直收
  end
  -- utils.log('[auto-cache-maker] Got full response data...')
  -- utils.log(respData)
  
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
  _cacheURIToMLCache(backendRequestCacheConf, ngx, respData)
  
  _cleanupCTX(ngx)
end

return M


