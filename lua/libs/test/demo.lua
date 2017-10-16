

describe("openresty script", function()
    it("should run in ngx_lua context", function()
        assert.equal(0, ngx.OK)
        assert.equal(200, ngx.HTTP_OK)
        -- print(ngx)
      end)
    it("should wait", function()
        -- ngx.sleep(1)
        assert.is_true(1 == 1)
      end)
end)
