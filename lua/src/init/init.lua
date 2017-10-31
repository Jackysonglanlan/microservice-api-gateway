
-- See https://github.com/openresty/lua-nginx-module#lua-variable-scope
local checkLUAEnv = require('init.check-LUA-ENV')
local addCommonUtils = require('init.add-common-utils')
local preloadLibs = require('init.preload-libs')


notInTest(function()
    _G.__yqj_global_cache = require('init.auto-cache')
end)

-- just to collect any garbage
-- collectgarbage("collect")
