
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
    lru_size = 500,        -- size of the L1 (Lua-land LRU) cache
    ttl      = 3600,       -- ttl for hits in seconds
  }
  
  -- defined in Openresty conf file by lua_shared_dict
  local cache, err = mlcache.new(name, "yqj_global_cache_dict", opts)
  
  -- fail fast: if you want to use cache, you MUST expect having it.
  if err then
    os.execute('echo "[YQJ] FATAL: Can not create global cache: '.. err .. ' - Quit!!" > /dev/stderr')
    os.exit(1);
  end
  
  return cache
end

-- main

_G.cache = _buildCache('yqj_global_cache', {
  lru_size = 1e5,        -- size of the L1 (Lua-land LRU) cache
  ttl      = 30,          -- ttl for hits in seconds
})


