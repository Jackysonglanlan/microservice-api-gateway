
-- see https://github.com/git-hulk/lua-resty-router for router usage

local function configRouter(router)
  -- _location_/foo-bar-test/a/111/222
  router:get("/a/:b/:c", function(params)
      ngx.say(JSON.encode({b = params.b, c = params.c}))
  end)
  
  -- _location_/foo-bar-test/b/c/aaa.html
  router:post("/b/c/*.html", function(params)
      utils.log("echo html")
  end)
  
  -- _location_/foo-bar-test/hello
  router:any("/hello", function(params)
      ngx.say(JSON.encode({foo = 123, bar = 456}))
  end)
  
end


-- export
return configRouter

