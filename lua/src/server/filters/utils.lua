
local insert = table.insert

local concat = table.concat

local M = {}

--[[
  - Get the full response data from backend server.
  -
  - Used in body_filter_by_lua_xxx filter
  - See https://github.com/openresty/lua-nginx-module#body_filter_by_lua
  -
  - @return string Full TEXT response data, or nil if the data is still coming
]]--
function M.bodyFilterGetFullRespData(ngx)
  -- nginx is running on non-blocking mode, so this method will be called many times until ngx.arg[2] == true
  
  -- tmp save chunks in ctx
  ngx.ctx.respDataChunks = ngx.ctx.respDataChunks or {}
  
  local chunk = ngx.arg[1]
  insert(ngx.ctx.respDataChunks, chunk)
  
  local isGetAllResp = ngx.arg[2]
  if not isGetAllResp then
    return -- return if there are still data to pass
  end
  
  local fullData = concat(ngx.ctx.respDataChunks, '')
  ngx.ctx.respDataChunks = nil
  return fullData
end


return M
