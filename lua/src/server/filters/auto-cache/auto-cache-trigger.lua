--
-- used in header_filter_by_lua_block directive
--
-- 这个 filter 会保存触发缓存的信息到 ngx.ctx.requestCacheConf，对应 backend response header X-YQJ-CACHE
--
---------

local AUTO_CACHE_KEY = require('init.auto-cache').type

-- 申请 auto-cache 的响应头格式: X-YQJ-CACHE -> JSONStr，json 格式如下:
--   type: 见 init.auto-cache
local YQJ_AUTO_CACHE_TRIGGER_HEADER = 'X-YQJ-CACHE'

local function _isReqGETAndResp200(ngx)
  local method = ngx.req.get_method()
  local statusCode = ngx.status
  return method == 'GET' and statusCode == ngx.HTTP_OK
end

local function _triggerAutoCache(ngx)
  conf = JSON.decode(ngx.header[YQJ_AUTO_CACHE_TRIGGER_HEADER])
  -- 把 type 转换为 "时间戳表示", 见 init.auto-cache
  conf.type = AUTO_CACHE_KEY[conf.type]
  
  -- utils.log(conf)
  ngx.ctx.requestCacheConf = conf
  ngx.header[YQJ_AUTO_CACHE_TRIGGER_HEADER] = nil -- clean this header, client shall never know
end

local function _saveCacheTypeToLastModifiedHeader(ngx, requestCacheConf)
  -- 这里，把 代表缓存类型的时间戳 写入 Last-Modified，这样就可以追踪客户端使用的哪个缓存了
  ngx.header['Last-Modified'] = requestCacheConf.type
end

-- main process

local M = {}

function M.triggerAutoCacheIfPossible(ngx)
  -- 只缓存成功的 GET 请求数据
  if not _isReqGETAndResp200(ngx) then
    local statusCode = ngx.status
    utils.wlog('[auto-cache-trigger] Request NOT GET or response code NOT 200, no cache... Resp code:' ..  statusCode)
    return
  end
  
  -- 没有 X-YQJ-CACHE 头，两种情况:
  --   1. 经过 backend 服务器, 但是 backend 不需要缓存(所以没有带这个头)
  --   2. 没有经过 backend 服务器，也就是说，auto-cache 生效了(才没有把请求转到 backend，所以没有这个头)
  if not ngx.header[YQJ_AUTO_CACHE_TRIGGER_HEADER] then
    return -- 两种情况都不需要启用缓存
  end
  
  -- utils.log('[auto-cache] Detected: backend server request auto-cache: ' + ngx.header[YQJ_AUTO_CACHE_TRIGGER_HEADER])
  
  -- 因为这个 filter 是唯一可以拿到 响应头 的 filter(处于 header_filter_by_lua_xxx 阶段)
  -- 所以需要把数据转存在 ngx.ctx 里面，后面的 auto-cache-maker 才能拿到
  _triggerAutoCache(ngx)
  
  -- 这里，把缓存类型存到 Last-Modified header 中，下次客户端请求时就会发 If-Modified-Since 上来，我们就拿到缓存类型了
  _saveCacheTypeToLastModifiedHeader(ngx, ngx.ctx.requestCacheConf)
end


return M
