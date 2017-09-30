
--[[
Lua Variable Scope:

Care must be taken when importing modules and this form should be used:

 local xxx = require('xxx')

instead of the old deprecated form:

 require('xxx')

Here is the reason: by design, the global environment has exactly the same lifetime as the Nginx request handler associated with it. Each request handler has its own set of Lua global variables and that is the idea of request isolation. The Lua module is actually loaded by the first Nginx request handler and is cached by the require() built-in in the package.loaded table for later reference, and the module() builtin used by some Lua modules has the side effect of setting a global variable to the loaded module table. But this global variable will be cleared at the end of the request handler, and every subsequent request handler all has its own (clean) global environment. So one will get Lua exception for accessing the nil value.

The use of Lua global variables is a generally inadvisable in the ngx_lua context as:

    the misuse of Lua globals has detrimental side effects on concurrent requests when such variables should instead be local in scope,
    Lua global variables require Lua table look-ups in the global environment which is computationally expensive, and
    some Lua global variable references may include typing errors which make such difficult to debug.

It is therefore highly recommended to always declare such within an appropriate local scope instead.

--]]


-- ///////////////

-- cjson is pre-loaded in nginx.conf via 'init_by_lua_block'
-- so below is fast-require

local cjson = require("cjson")
local resty_md5 = require "resty.md5"
local string = require "resty.string"

-- override nginx config: response json header instead
ngx.header["Content-Type"] = "application/json"

local sign =ngx.escape_uri('aaa=111&bbb=222&ccc=333&Host=h1&User-Agent=h2&xxx=h3&yyy=h4')
local md5 = resty_md5:new()

local ok = md5:update(sign)
if not ok then
  return
end

local md5 = string.to_hex(md5:final())

ngx.say(cjson.encode({foo=123, bar="text", md5=md5}))
