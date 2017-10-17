

describe("Openresty test context", function()
    it("should run in ngx_lua context", function()
        assert.equal(0, ngx.OK)
        assert.equal(200, ngx.HTTP_OK)
      end)
    
    it("should wait", function()
        ngx.sleep(0.1)
        assert.is_true(1 == 1)
      end)
    
    describe("Preload libs and functions", function()
        it("should pre-define environment functions", function()
            local shouldExecFuncList = {inTest, notInDev, notInProd}
            _.each(shouldExecFuncList, function(_, fun)
                fun(function()
                    assert.is_true(true)
                        end)
                  end)
            
            local notExecFuncList = {notInTest, inDev, inProd}
            _.each(notExecFuncList, function(_, fun)
                fun(function()
                    assert.is_true(false) -- 不会进到这里，所以测试不会报错
                        end)
                  end)
            end)
        
        it("should load _", function()
            local arr = {'aa', 'bb', 'cc'}
            _.each(arr, function(k, v)
                utils.log(v)
                  end)
            end)
        
        it("should load JSON", function()
            --
            utils.log(JSON.encode({a = 1, b = 2, c = 3}))
            end)
      end)
    
    
end)
