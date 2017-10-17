
local ENV = {'dev', 'prod', 'test'}
local runningEnv = os.getenv("LUA_ENV")

local function _mustHaveLUA_ENV()
  local found = false
  for _, env in pairs(ENV) do
    if string.match(runningEnv, env .. '.*') then
      found = true
      break
    end
  end
  
  if not found then
    os.execute('echo "[YQJ] FATAL: Illegal or Missing LUA_ENV (valid value: dev prod test)... Quit!!"')
    os.exit(1);
  end
end

_mustHaveLUA_ENV()

---------------------
----- start init ----
---------------------

-- introduce LUA_ENV:

local function _envFunctionFactory(targetEnv, notIn)
  return   function(fun)
    local foundEnv = _G._.select(ENV, function(k, supportedEnv)
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

-- core class extension
require('luacat.luacat.luacat') -- 注意: luacat 库自带的 moacat 是一个做游戏的 sdk, 没有使用，但是也没有删除

-- mount everyday use modules to global
_G.JSON = require('libcjson.libcjson')
_G.utils = require('yqj.utils')(ngx)
_G.utils.regex = require('regex.regex')

-- lua lodash
_G._ = require('moses.moses_min')

-- Lua env handler
_G.inDev = _envFunctionFactory('dev')
_G.notInDev = _envFunctionFactory('dev', true)

_G.inProd = _envFunctionFactory('prod')
_G.notInProd = _envFunctionFactory('prod', true)

_G.inTest = _envFunctionFactory('test')
_G.notInTest = _envFunctionFactory('test', true)

-- just to collect any garbage
-- collectgarbage("collect")
