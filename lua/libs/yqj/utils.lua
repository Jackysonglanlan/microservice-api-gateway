

local cjson = require("cjson")

local _M={}

function _M.debug(...)
  printAllArgs = function ( args )
    content = {}
    count = 0
    for k,v in ipairs(args) do
      kv = ''
      if type(v) == 'table' then
        kv = cjson.encode(v)
      else
        kv = v
      end
      table.insert(content, '[DEBUG] - arg[')
      table.insert(content, k)
      table.insert(content, ']: ')
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



-- export, like node.js module.export = ...
return function ( ngx )
  _M.ngx = ngx
  return _M
end
