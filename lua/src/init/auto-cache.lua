
------------------------
-- multi-level cache
-- see https://github.com/thibaultcha/lua-resty-mlcache
------------------------

local mlcache = require("resty.mlcache")

--[[
  - Build a multi-level cache.
  -
  - @param  {string} name The name of the cache
  - @param  {table}  opts Cache options, can be nil(use default)
  -
  - @return cache   The cache object.
]]--
local function _buildCache(name, opts)
  opts = opts or {
    lru_size = 1000,                      -- size of the L1 (Lua-land LRU) cache
    ttl      = 60 * 60,                   -- ttl for hits in seconds
  }
  
  -- defined in Openresty conf file by directive: lua_shared_dict
  local cache, err = mlcache.new(name, "yqj_global_cache_dict", opts)
  
  -- fail fast: if you want to use cache, you MUST expect having it.
  if err then
    os.execute('echo "[YQJ] FATAL: Can not create global cache: '.. err .. ' - Quit!!" > /dev/stderr')
    os.exit(1);
  end
  
  return cache
end

local function _buildTTLCache(cacheStore, ttlType, ttl)
  cacheStore.cache = cacheStore.cache or {}
  cacheStore.cache[cacheStore.type[ttlType]] = _buildCache(ttlType, {
    lru_size = 1e5, 
    ttl      = ttl, 
  })
end

-- main

-- cache 结构:
-- { cache = {
--     UTC time stamp = MLCache
--   },
--   type = {
--     type-string = UTC time stamp
--   }
-- }
local cache = {}

-- 这里，由于缓存是借助 Last-Modified 由客户端指定的，所以为了方便查找，缓存的 type 就是时间戳
-- 把时间戳当 cache type 来用，这样就可以使用不同的缓存
cache.type = {}
cache.type.ttl_30s = 'Thu, 01 Jan 1970 00:00:01 GMT'
cache.type.ttl_5m = 'Thu, 01 Jan 1970 00:00:02 GMT'
cache.type.ttl_1h = 'Thu, 01 Jan 1970 00:00:03 GMT'

-- build cache
_buildTTLCache(cache, 'ttl_30s', 30)
_buildTTLCache(cache, 'ttl_5m', 60 * 5)
_buildTTLCache(cache, 'ttl_1h', 60 * 60)

return cache

