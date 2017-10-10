
local Router = {}

-- see https://github.com/git-hulk/lua-resty-router
local RealRouter = require('router.router')
local realRouter = RealRouter:new()

local cache = {}

local function _loadRouteFile(fileRequirePath)
  local    route = require(fileRequirePath)
  route(realRouter)
  -- utils.log(realRouter)
  return route
end

--[[
  - Dispatch request to their corresponding route files.
  -
  - @param  {string} apiPrefix
  - @param  {string} filePath  the path of corresponding route file relative to lua/src/server/routes
]]--
function Router.dispatch(apiPrefix, filePath, uri)
  -- utils.log(filePath, uri)
  
  local fileRequirePath = 'server.routes.' .. string.gsub(filePath, '-', '.')
  local paramURI = uri
  
  local route = cache[fileRequirePath]
  if not route then
    route = _loadRouteFile(fileRequirePath)
    cache[fileRequirePath] = route
  end
  
  -- pass api prefix to router
  apiPrefix = apiPrefix .. '/' .. filePath
  realRouter:run(apiPrefix )
end


-- API匹配规则:
--    apiPrefix/router-file-path/routeRule
--
-- 其中
-- apiPrefix:
--     可以从配置文件指定，需要和 nginx URI 规则一致, 比如:
--     location ~ ^/api/([^/]+)/?(.*) {
--       content_by_lua_block{
--         local router = require('server.router')
--         router.dispatch('/api', ngx.var[1], ngx.var[2]) -- 等价于 nginx $1 $2
--       }
--     }
--
-- router-file-path:
--     用 '-' 分割, 比如 foo-bar-test 代表 lua/src/server/routes/foo/bar/test.lua 路由文件
--
-- routeRule
--     路由文件中定义的路由规则

return Router


