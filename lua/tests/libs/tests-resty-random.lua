
describe("random", function()
    --
    it("should work", function()
        --
        local random = require "yqj.random"
        rand = (random.bytes(10, "hex"))
        assert.equal(20, string.len(rand))
      end)
    
end)

