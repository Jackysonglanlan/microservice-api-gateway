
describe("Openresty C libs", function()
  
  local function walkAllFilesRecursive(path, cb)
    local lfs = require("lfs")
    for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
        local f = path .. '/' .. file
        local attr = lfs.attributes (f)
        assert.equal('table', type(attr))
        if attr.mode == "directory" then
          walkAllFilesRecursive(f, cb)
        else
          cb(f)
          --   for name, value in pairs(attr) do
          --     utils.log(name, value)
          -- end
        end
      end
    end
  end
  
  it("should load lfs", function()
    walkAllFilesRecursive('lua/libs/.prebuild', function(f)
      assert.is_true(f:startsWith(f, 'lua/libs/.prebuild'))
    end)
  end)
  
  it("should load JSON", function()
    assert.equal('{"foo":112,"bar":"bbb"}', JSON.encode({foo = 112,  bar = 'bbb'}))
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
    local result = {}
    for _, match in pairs(hits) do
      table.insert(result, string.sub(text, start, match.to))
      start = match.to + 1
    end
    
    assert.equal(text, table.concat(result, ''))
  end)
  
end)

