
describe("Preload libs and functions", function()
  it("should load _", function()
    local arr = {'aa', 'bb', 'cc'}
    assert.equal(1, _.findIndex(arr, 'aa'))
  end)
  
  it("should pre-define environment functions", function()
    local shouldExecFuncList = {inTest, notInDev, notInProd}
    _.forEach(shouldExecFuncList, function(fun)
      fun(function() assert.is_true(true) end)
    end)
    
    local notExecFuncList = {notInTest, inDev, inProd}
    _.forEach(notExecFuncList, function(fun)
      fun(function()
        assert.is_true(false) -- 不会进到这里，所以测试不会报错
      end)
    end)
  end)
  
  it("should load JSON", function()
    assert.equal('{"b":2,"a":1,"c":3}', JSON.encode({a = 1, b = 2, c = 3}))
  end)
  
  it("should load Path", function()
    --
    assert.equal('table', type(utils.Path))
  end)
  
  
end)




