
describe("timer", function()
    --
    it("should wait then call", function()
        --
        local counter = 0
        uv.timer(loop):start(500, 100, function(timer)
            print("Tick #" .. counter .. ' ', timer, timer:loop())
            assert.equal(loop, timer:loop())
            counter = counter + 1
            if counter == 5 then
              timer:close(function() print("Close") end)
            end
            end)
        loop.run()
      end)
end)
