-------------------
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
    lru_size = 1000,          -- size of the L1 (Lua-land LRU) cache
    ttl      = 60 * 60,       -- ttl for hits in seconds
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

local function _buildTTLCache(cacheStore, cacheType, ttl, lruSize)
  cacheStore.cache = cacheStore.cache or {}
  cacheStore.cache[cacheStore.type[cacheType]] = _buildCache(cacheType, {
    lru_size = lruSize, 
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
-- WARN: 为了不干扰正常的 Last-Modified 机制, 这里统一使用 1970.01.01 这一天内的值(正常的值不会是这一天)
cache.type = {}
cache.type.default = 'Thu, 01 Jan 1970 00:00:00 GMT'

-- build cache
_buildTTLCache(cache, 'default', 1, 1e6)

return cache
