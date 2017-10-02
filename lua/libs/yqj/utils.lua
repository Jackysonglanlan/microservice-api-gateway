
local utils={}

local inspect = require('inspect.inspect')

function utils.deepcompare(t1,t2,ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end
  -- non-table types can be directly compared
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
  -- as well as tables which have the metamethod __eq
  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then return t1 == t2 end
  for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not utils.deepcompare(v1,v2) then return false end
  end
  for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not utils.deepcompare(v1,v2) then return false end
  end
  return true
end

function utils.deepcopy(t)
  if type(t) ~= 'table' then return t end
  local mt = getmetatable(t)
  local res = {}
  for k,v in pairs(t) do
    if type(v) == 'table' then
      v = utils.deepcopy(v)
    end
    res[k] = v
  end
  setmetatable(res,mt)
  return res
end

function utils.islist(t)
  local itemcount = 0
  local last_type = nil
  for k,v in pairs(t) do
    itemcount = itemcount + 1
    if last_type == nil then
      last_type = type(v)
    end

    if type(v) ~= last_type or (type(v) ~= "string" and type(v) ~= "number" and type(v) ~= "boolean") then
      return false
    end

    last_type = type(v)
  end

  if itemcount ~= #t then
    return false
  end

  return true
end

local function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil

    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
        return key, t[key]
    end
    -- fetch the next value
    key = nil
    for i = 1,table.getn(t.__orderedIndex) do
        if t.__orderedIndex[i] == state then
            key = t.__orderedIndex[i+1]
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function utils.orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

--[[
  - Log to html.
  -
  - @param  {Any} ... | Any lua value
]]--
function utils.hlog(...)
  local printAllArgs = function ( args )
    local content = {}
    local count = 0
    for k,v in ipairs(args) do
      local kv = inspect(v)
      table.insert(content, '[DEBUG] - <span style="color:black">[')
      table.insert(content, k)
      table.insert(content, ']:</span> ')
      table.insert(content, kv)
      table.insert(content, '<br>')
      content[count] = '<br>'
    end
    return table.concat(content)
  end

  -- override nginx config: response html
  utils.ngx.header["Content-Type"] = "text/html"
  utils.ngx.say([[
    <p>
      <b style='color:red; font-size:20px'> ]] .. printAllArgs({...}) .. [[</b>
    </p>
  ]])
  utils.ngx.exit(ngx.HTTP_OK)
end

local function _extract_filename_line_for_log_info(traceback)
  local PLAIN = true
  local tailcall = string.find(traceback, '(tail call): ?', 1, PLAIN)
  local text = nil
  local index = -1
  if nil == tailcall then
    text = traceback
  else
    local from = 1
    text = String.slice(traceback, from, tailcall)
  end

  local realLoc = String.split(text,": in function ")[2]
  realLoc = String.split(realLoc,"\n")[2]
  realLoc = String.lstrip(realLoc)

  return realLoc
end

local function _log(level)
  return function ( ... )
    local buff = {}
    -- first line, the real log location
    table.insert(buff, '<' .. _extract_filename_line_for_log_info(debug.traceback()) .. '>')
    for i,v in ipairs({...}) do
      table.insert(buff, inspect(v,{depth = 4}))
    end
    utils.ngx.log(level, '\n' .. table.concat(buff, ",\n") .. '\n')
  end
end

-- export, like node.js module.export = ...
return function ( ngx )
  utils.ngx = ngx

  utils.log = _log(ngx.INFO) -- info log
  utils.alog = _log(ngx.ALERT) -- alert log
  utils.elog = _log(ngx.ERROR) -- error log

  return utils
end
