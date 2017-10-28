
---------
-- used in header_filter_by_lua_xxx directive
--
-- 这个 filter 会保存触发缓存的信息到 ngx.ctx.__autoCache，有如下 key:
--   enabled: bool 是否需要触发 auto-cache，对应 backend response header X-YQJ-CACHE
--
-- 注意: 如果缓存已经存在，请求是到不了这个 filter 的，在 auto-cache 那里就会被拦截
---------

-- TODO:
-- backend 服务器可以指定 cache 类型, 而不单单是 true/false
-- 比如 small_few_short(适用于碎片数据) | big_mass_long(适用于大块数据)
-- 但是这种功能需要 请求发起方 配合，意味着缓存不再透明
local YQJ_AUTO_CACHE_TRIGGER_HEADER = 'X-YQJ-CACHE'

local function _saveThenCleanHeader(header, ctxKey)
  if not ngx.header[header] then
    return
  end
  
  ngx.ctx.__autoCache[ctxKey] = ngx.header[header]
  ngx.header[header] = nil -- clean this header, client shall never know
end

local function _saveAutoCacheTriggerDataToCTX()
  ngx.ctx.__autoCache = ngx.ctx.__autoCache or {}
  
  _saveThenCleanHeader(YQJ_AUTO_CACHE_TRIGGER_HEADER, 'enabled')
end

-- main process

_saveAutoCacheTriggerDataToCTX()
