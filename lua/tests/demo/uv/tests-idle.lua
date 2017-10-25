
describe("idle", function()
    --
    it("should keep loop running", function()
        local counter = 0
        uv.idle(loop):start(function(idle)
            counter = counter + 1
            if counter > 10e4 then
              idle:stop()
              print('idle stop')
            end
            end)
        loop.run()
      end)
end)
