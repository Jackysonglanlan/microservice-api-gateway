
---------
-- used in header_filter_by_lua_xxx directive
--
-- 这个 filter 会保存触发缓存的信息到 ngx.ctx.requestCacheConf，对应 backend response header X-YQJ-CACHE
--
---------

-- 申请 auto-cache 的响应头格式: X-YQJ-CACHE -> JSONStr，json 格式如下:
--   type: small_mass_short(适用于碎片数据) 或 big_few_long(适用于大块数据)
local YQJ_AUTO_CACHE_TRIGGER_HEADER = 'X-YQJ-CACHE'

-- 没有 X-YQJ-CACHE 头，代表并没有经过 backend 服务器，也就是说，auto-cache 生效了(才没有把请求转到 backend，所以没有这个头)

if not ngx.header[YQJ_AUTO_CACHE_TRIGGER_HEADER] then
  return -- 所以下面不需要处理了
end

utils.log('[auto-cache] Detected: backend server request auto-cache: ' + ngx.header[YQJ_AUTO_CACHE_TRIGGER_HEADER])

local function _saveCacheConfDataToCTX(ctx)
  ctx.requestCacheConf = JSON.decode(ngx.header[YQJ_AUTO_CACHE_TRIGGER_HEADER])
  ngx.header[YQJ_AUTO_CACHE_TRIGGER_HEADER] = nil -- clean this header, client shall never know
end

local function _saveCacheTypeToLastModifiedHeader(requestCacheConf)
  -- WARN: 有风险！根据 http 协议，Last-Modified 应该是一个时间戳，这里传了个字符串，某些客户端可能不认
  ngx.header['Last-Modified'] = requestCacheConf.type
end

-- main process

-- 因为这个 filter 是唯一可以拿到 响应头 的 filter(处于 header_filter_by_lua_xxx 阶段)
-- 所以需要把数据转存在 ctx 里面，后面的 auto-cache-maker 才能拿到
_saveCacheConfDataToCTX(ngx.ctx)

-- 这里，把缓存类型存到 Last-Modified header 中，下次客户端请求时就会发 If-Modified-Since 上来，我们就拿到缓存类型了
_saveCacheTypeToLastModifiedHeader(ngx.ctx.requestCacheConf)

