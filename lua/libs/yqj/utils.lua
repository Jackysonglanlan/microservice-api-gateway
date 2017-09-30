

local cjson = require("cjson")

local _M={}

function _M.debug(...)
  printAllArgs = function ( args )
    local content = {}
    local count = 0
    for k,v in ipairs(args) do
      local kv = ''
      if type(v) == 'table' then
        kv = cjson.encode(v)
      else
        kv = v
      end
      table.insert(content, '[DEBUG] - <span style="color:black">[')
      table.insert(content, k)
      table.insert(content, ']:</span> ')
      table.insert(content, kv)
      table.insert(content, '<br>')
      content[count] = '<br>'
    end
    return table.concat(content)
  end

  args = {...}
  _M.ngx.say([[
    <p>
      <b style='color:red; font-size:20px'> ]] .. printAllArgs(args) .. [[</b>
    </p>
  ]])
end

-- Merge many table into one.
-- All params must be instance of table.
function _M.tableMerge( ... )
  local tmp = {}
  for n,param in pairs({...}) do
    if type(param) == 'table' then
      for k,v in pairs(param) do
        tmp[k] = v
      end
    end
  end
  return tmp
end


-- export, like node.js module.export = ...
return function ( ngx )
  _M.ngx = ngx
  return _M
end
