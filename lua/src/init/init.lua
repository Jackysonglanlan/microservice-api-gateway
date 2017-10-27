

require('init.check-LUA-ENV')

require('init.add-common-utils')

notInTest(function()
    local Cache = require('init.ml-cache')
    local cache = Cache('yqj_global_cache')
    _G.cache = cache
end)


-- just to collect any garbage
-- collectgarbage("collect")
