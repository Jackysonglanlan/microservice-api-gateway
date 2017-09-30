

utils = require('yqj.utils')(ngx)

local headers = ngx.req.get_headers()

-- TODO: get params

function genePresignStrFromParamsAndHeaders( paramHeaderTable )
  a = {}
  for n in pairs(paramHeaderTable) do table.insert(a, n) end
  table.sort(a)

  sorted = {}
  for k,sortedKey in pairs(a) do
    if sortedKey ~= 'sign' then
      table.insert(sorted, sortedKey..'='..paramHeaderTable[sortedKey]..'&')
    end
  end
  sortedStr = table.concat(sorted)
  return sortedStr
end

function escapeStr( presignStr )
  return ngx.escape_uri(presignStr)
end

-- TODO: sign with md5

presignStr = genePresignStrFromParamsAndHeaders(headers)

finalStr = escapeStr(presignStr)

utils.debug('sortedStr: ', finalStr)

