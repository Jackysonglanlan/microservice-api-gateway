

describe("Openresty test context", function()
    it("should run in ngx_lua context", function()
        assert.equal(0, ngx.OK)
        assert.equal(200, ngx.HTTP_OK)
      end)
    
    it("should wait", function()
        ngx.sleep(0.1)
        assert.is_true(1 == 1)
      end)
end)


describe("Openresty C libs", function()
    
    local function printAllFilesRecursive(path)
      local lfs = require("lfs")
      for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
          local f = path .. '/' .. file
          local attr = lfs.attributes (f)
          assert (type(attr) == "table")
          if attr.mode == "directory" then
            printAllFilesRecursive (f)
          else
            utils.log(f)
            --   for name, value in pairs(attr) do
            --     utils.log(name, value)
            -- end
          end
        end
      end
    end
    
    it("should load lfs", function()
        printAllFilesRecursive('lua/libs/.prebuild')
      end)
    
    it("should load jit-uuid and JSON", function()
        local uuid = require('yqj.jit-uuid')
        utils.log( JSON.encode({foo = 112, uuid = uuid.generate_v4(), md5 = md5}))
      end)
    
    pending("should load libuv to make http request", function()
        local uv = require("lluv")
        local curl = require "lluv.curl"
        local loop = uv.default_loop()
        
        local function writeToResp(data)
          -- utils.log(data)
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
      end)
    
    it("should load luahs", function()
        local hs = require('luahs') -- need gcc to have "GLIBCXX_3.4.20", or it will fail
        db = hs.compile {
          expression = '\\w\\b', 
          mode = hs.compile_mode.HS_MODE_BLOCK, 
          flags = {
            hs.pattern_flags.HS_FLAG_CASELESS, 
            hs.pattern_flags.HS_FLAG_MULTILINE, 
            -- hs.pattern_flags.HS_FLAG_UTF8,
            -- hs.pattern_flags.HS_FLAG_UCP,
                }
            }
        scratch = db:makeScratch()
        
        local text = 'or it will fail'
        hits = db:scan(text, scratch)
        
        local start = 0
        for _, match in pairs(hits) do
          utils.log( string.sub(text, start, match.to))
          start = match.to + 1
        end
        
      end)
    
end)

