
--[[
Lua Variable Scope:

Care must be taken when importing modules and this form should be used:

 local xxx = require('xxx')

instead of the old deprecated form:

 require('xxx')

Here is the reason: by design, the global environment has exactly the same lifetime as the Nginx request handler
associated with it. Each request handler has its own set of Lua global variables and that is the idea of request
isolation. The Lua module is actually loaded by the first Nginx request handler and is cached by the require() built-in
in the package.loaded table for later reference, and the module() builtin used by some Lua modules has the side effect
of setting a global variable to the loaded module table. But this global variable will be cleared at the end of the
request handler, and every subsequent request handler all has its own (clean) global environment.

So one will get Lua exception for accessing the nil value.

The use of Lua global variables is a generally inadvisable in the ngx_lua context as:

    the misuse of Lua globals has detrimental side effects on concurrent requests when such variables should instead
    be local in scope, Lua global variables require Lua table look-ups in the global environment which is computationally
    expensive, and some Lua global variable references may include typing errors which make such difficult to debug.

It is therefore highly recommended to always declare such within an appropriate local scope instead.

--]]


-- ///////////////

local function testLuahs()
  local hs = require('luahs') -- need gcc to have "GLIBCXX_3.4.20", or it will fail
  db = hs.compile {
    expression = 'aaa', 
    mode = hs.compile_mode.HS_MODE_BLOCK, 
  }
  scratch = db:makeScratch()
  
  hits = db:scan('aaa', scratch)
  
  utils.log(hits)
end
-- testLuahs()

local function testHttpipe(url)
  local httpipe = require('http.httpipe')
  local hp, err = httpipe:new(100)
  
  local ok, err = hp:connect(url, 80)
  if not ok then
    utils.log("failed to request: ", err)
    return
  end
  local ok, err = hp:send_request({method = "GET" })
  
  local res = {}
  hp:read_response({body_filter = function(data)
      table.insert(res, data)
  end})
  
  utils.log(table.concat(res, ''))
end
-- testHttpipe('www.baidu.com')

local function performHttpRequest()
  local uv = require("lluv")
  local curl = require "lluv.curl"
  local loop = uv.default_loop()
  
  local function writeToResp(data)
    utils.log(data)
  end
  
  local easy = curl.easy({
    url = "http://www.baidu.com";
    writefunction = writeToResp
  })
  
  local multi = curl.multi()
  multi:add_handle(easy, function(easy, err)
      utils.log("Done:", err or easy:getinfo_response_code())
      uv.stop(loop) -- stop the loop, or it will block the nginx thread
  end)
  uv.run(loop)
end
-- performHttpRequest()

local function md5AndCJSON()
  local resty_md5 = require "resty.md5"
  local string = require "resty.string"
  
  local sign = ngx.escape_uri('aaa=111&bbb=222&ccc=333&Host=h1&User-Agent=h2&xxx=h3&yyy=h4')
  local md5 = resty_md5:new()
  
  local ok = md5:update(sign)
  if not ok then
    return
  end
  local md5 = string.to_hex(md5:final())
  
  local uuid = require('yqj.jit-uuid')
  
  ngx.say(JSON.encode({foo = 112, uuid = uuid.generate_v4(), md5 = md5}))
end
md5AndCJSON()

local function testLFS(path)
  local lfs = require("lfs")
  
  for file in lfs.dir(path) do
    if file ~= "." and file ~= ".." then
      local f = path .. '/' .. file
      utils.log(f)
      local attr = lfs.attributes (f)
      assert (type(attr) == "table")
      if attr.mode == "directory" then
        testLFS (f)
        -- else
        --   for name, value in pairs(attr) do
        --     utils.log(name, value)
        --   end
      end
    end
  end
end
-- testLFS('lua/libs/.prebuild')

local function unittest()
  local iresty_test    = require ("test.resty_test")(ngx)
  local tb = iresty_test.new({unit_name = "example"})
  
  function tb:init(  )
    self:log("init complete")
  end
  
  function tb:test_00001(  )
    error("invalid input")
  end
  
  function tb:atest_00002()
    self:log("never be called")
  end
  
  function tb:test_00003(  )
    self:log("ok")
  end
  
  -- units test
  tb:run()
end
-- unittest()

local function testTamale()
  local tamale =  require "tamale.tamale"
  local V = tamale.var
  local M = tamale.matcher {
    { {"foo", 1, {} },      "one" }, 
    { 10,                   function() return "two" end}, 
    { {"bar", 10, 100},     "three" }, 
    { {"baz", V"X" },       V"X" },                                       -- V"X" is a variable
    { {"add", V"X", V"Y"},  function(cs) return cs.X + cs.Y end }, 
  }
  
  utils.log(M({"foo", 1, {}}))   --> "one"
  utils.log(M(10))               --> "two"
  utils.log(M({"bar", 10, 100})) --> "three"
  utils.log(M({"baz", "four"}))  --> "four"
  utils.log(M({"add", 2, 3}))     --> 5
  utils.log(M({"sub", 2, 3}))    --> nil, "Match failed"
end
-- testTamale()

local function testPLDate()
  local Date = require('pl.Date')
  utils.log(Date(1):__tostring())
end
-- testPLDate()

local function testEventable()
  local et = require('eventable.eventable')
  
  --Create some new evented tables
  local cook = et:new()
  local waiter = et:new()
  
  --Cook waits for order
  cook:on('order', function( evt, food )
      utils.log('Now cooking' .. food)
      -- ...
      cook:emit( 'order-up', food )
  end)
  
  --Waiter listens for order
  waiter:on('order-up', function( evt, food )
      utils.log( 'Your ' .. food .. ' are served.')
  end)
  
  --Waiter places order
  waiter:emit('order', 'Pancakes')
end
-- testEventable()





