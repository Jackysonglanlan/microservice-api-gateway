

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
local strong = require('yqj.strong')

-- mount everyday use modules to global
_G.JSON = require('libcjson.libcjson')

local utils = require('yqj.utils')(ngx)
utils.regex = require('regex.regex')
utils.Date = require('yqj.date')
utils.Path = require('yqj.path')
_G.utils = utils

-- lua lodash
_G._ = require('moses.moses')

