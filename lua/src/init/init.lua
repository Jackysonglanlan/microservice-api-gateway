

require('init.check-LUA-ENV')

require('init.add-common-utils')


notInTest(function()
    require('init.auto-cache')
end)


-- just to collect any garbage
-- collectgarbage("collect")
