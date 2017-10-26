
local VALID_ENV = {'dev', 'prod', 'test'}
local runningEnv = os.getenv("LUA_ENV") or ''

------- introduce LUA_ENV:

local function _mustHaveLUA_ENV()
  local found = false
  for _, env in pairs(VALID_ENV) do
    if string.match(runningEnv, env .. '.*') then
      found = true
      break
    end
  end
  
  if not found then
    os.execute('echo "[YQJ] FATAL: Illegal or Missing LUA_ENV (valid value: dev prod test)... Quit!!" > /dev/stderr')
    os.exit(1);
  end
end

_mustHaveLUA_ENV()

local function _arrSelect(t, f, ...)
  local _t = {}
  for index, value in pairs(t) do
    if f(index, value, ...) then _t[#_t + 1] = value end
  end
  return _t
end

local function _envFunctionFactory(targetEnv, notIn)
  return   function(fun)
    local foundEnv = _arrSelect(VALID_ENV, function(k, supportedEnv)
        return string.match(runningEnv, supportedEnv .. '.*')
    end)
    
    local matchEnv = (targetEnv == foundEnv[1])
    if notIn and not matchEnv then
      fun()
    end
    if not notIn and matchEnv then
      fun()
    end
  end
end

-- Lua env handler
_G.inDev = _envFunctionFactory('dev')
_G.notInDev = _envFunctionFactory('dev', true)

_G.inProd = _envFunctionFactory('prod')
_G.notInProd = _envFunctionFactory('prod', true)

_G.inTest = _envFunctionFactory('test')
_G.notInTest = _envFunctionFactory('test', true)

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

-- just to collect any garbage
-- collectgarbage("collect")
