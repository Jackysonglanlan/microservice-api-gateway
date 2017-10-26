
local redis = require('resty.redis-util')

describe("resty-redis-util", function()
    it("should connect to redis", function()
        local conn = redis:new({
          host = '127.0.0.1', 
          port = 6379, 
          db_index = 0, 
          password = nil, 
          timeout = 1000, 
          keepalive = 60000, 
          pool_size = 100
            });
        
        local ok, err = conn:ping()
        
        if not ok then
          print("failed to ping:", err)
          return
        end
        
        print("ping result: ", ok)
      end)
end)

