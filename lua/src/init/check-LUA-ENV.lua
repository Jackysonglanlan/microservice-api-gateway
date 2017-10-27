
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

