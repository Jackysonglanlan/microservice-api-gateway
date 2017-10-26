
local url = 'www.baidu.com'

describe("cosocket", function()
    -- see https://www.openresty.com.cn/pra_ngx_lua_whats_cosocket.html
    pending("should perform non-blocking socket", function()
        local sock = ngx.socket.tcp()
        local ok, err = sock:connect(url, 80)
        if not ok then
          print("failed to connect to baidu: ", err)
          return
        end
        
        local req_data = 'GET / HTTP/1.1\r\nHost: ' .. url .. '\r\n\r\n'
        local bytes, err = sock:send(req_data)
        if err then
          print("failed to send to baidu: ", err)
          return
        end
        
        local data, err, partial = sock:receive()
        if err then
          print("failed to recieve to baidu: ", err)
          return
        end
        
        sock:close()
        print('successfully talk to ' .. url .. '! response first line: ', data)
      end)
    
end)
