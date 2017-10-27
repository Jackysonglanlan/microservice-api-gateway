

-------------------------
---- dev helper init ----
-------------------------

--[[
  - 用于查看代码是否被 jit 优化
  -
  - 对于没有被 JIT 优化的代码，日志会出现 NYI（Not Yet Implemented）关键字，例如:
  - [TRACE --- (4/0) date.lua:636 -- NYI: bytecode 51]
  -
  - see https://moonbingbing.gitbooks.io/openresty-best-practices/content/something/2016_8.html
]]--
local function jitDebug()
  _G.inDev(function()
      local v = require "jit.v"
      v.on("logs/jit.bailout.log")
  end)
end
jitDebug()

---------------------
----- start init ----
---------------------

-- core class extension
_G.String = require('yqj.StringExt')
_G.Date = require('yqj.date')
_G.Path = require('yqj.path')

-- mount everyday use modules to global
_G.JSON = require('libcjson.libcjson')
_G.utils = require('yqj.utils')(ngx)
_G.utils.regex = require('regex.regex')

-- lua lodash
_G._ = require('moses.moses')

