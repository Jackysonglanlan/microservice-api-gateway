
local utils = {}

local inspect = require('inspect.inspect')

local logger = require('yqj.logger')
function utils.islist(t)
  local itemcount = 0
  local last_type = nil
  for k, v in pairs(t) do
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

--[[
  - Log to html.
  -
  - @param  {Any} ... | Any lua value
]]--
function utils.hlog(...)
  local printAllArgs = function ( args )
    local content = {}
    local count = 0
    for k, v in ipairs(args) do
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
    < p > 
    < b style = 'color:red; font-size:20px' > ]] .. printAllArgs({...}) .. [[ < / b > 
    < / p > 
  ]])
  utils.ngx.exit(ngx.HTTP_OK)
end

local function _extract_filename_line_for_log_info(traceback)
  local PLAIN = true
  local tailcall = string.find(traceback, '(tail call): ?', 1, PLAIN)
  local text = nil
  local index = - 1
  if nil == tailcall then
    text = traceback
  else
    local from = 1
    text = String.slice(traceback, from, tailcall)
  end
  
  local realLoc = String.split(text, ": in function ")[2]
  realLoc = String.split(realLoc, "\n")[2]
  realLoc = String.lstrip(realLoc)
  
  return realLoc
end

local function _log(level)
  local log = logger:new(level, 'logs/yqj.' .. level .. '.log' )
  
  return function ( ... )
    local buff = {}
    -- first line, the real log location
    table.insert(buff, '<' .. _extract_filename_line_for_log_info(debug.traceback()) .. '>')
    for i, v in ipairs({...}) do
      table.insert(buff, inspect(v, {depth = 4}))
    end
    
    log[level](log, table.concat(buff, ",\n") .. '\n')
  end
end

-- export, like node.js module.export = ...
return function ( ngx )
  utils.ngx = ngx
  
  utils.log = _log('info') -- info log
  utils.alog = _log('alert') -- alert log
  utils.elog = _log('error') -- error log
  utils.dlog = _log('debug') -- error log
  
  return utils
end
