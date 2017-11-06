
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
    lru_size = 1000,           -- size of the L1 (Lua-land LRU) cache
    ttl      = 60 * 60,        -- ttl for hits in seconds
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

-- main

local cache = {}

cache.small_mass_short = _buildCache('small_mass_short', {
  lru_size = 1e5,    -- size of the L1 (Lua-land LRU) cache
  ttl      = 10,     -- ttl for hits in seconds
})

cache.big_few_long = _buildCache('big_few_long', {
  lru_size = 1e3,            -- size of the L1 (Lua-land LRU) cache
  ttl      = 60 * 30,        -- ttl for hits in seconds
})

return cache





