
local ffi = require 'ffi'

-- 声明要使用的 c 函数
-- 其实并不需要 .h 文件，但是为了查询 API 方便，最好还是把 .h 加到项目中
ffi.cdef[[
  char * haha();
]]

-- 声明结构体
ffi.cdef[[
  typedef struct cfoo{
    int timestamp;
    } cfoo;
]]

describe("FFI", function()
    
    setup(function()
        -- 编译动态库
        os.execute('cd lua/tests/demo && make')
      end)
    
    it("should load C lib", function()
        local c = ffi.load("lua/tests/demo/libhelloworld.so")
        
        -- userdata 代表数据是 C 的结构
        assert.equal('userdata', type(c))
        -- 调用 c 函数，返回的 char* 需要转换为 lua string
        assert.equal('haha', ffi.string(c.haha()))
      end)
    
    
    it("should use C struct", function()
        --
        local size = ffi.sizeof('cfoo') -- 计算这个结构体占用的内存大小
        assert.equal(size, 4) -- (由于只有一个 int，所以是 4 byte)
        
        local ptr = ffi.typeof('cfoo *')
        assert.equal(tostring(ptr), 'ctype<struct cfoo *>')
        
        local data = ffi.new('cfoo') -- 使用结构体
        local ts = os.time(os.date("!*t"))
        data.timestamp = ts
        assert.equal(data.timestamp, ts)
      end)
end)



