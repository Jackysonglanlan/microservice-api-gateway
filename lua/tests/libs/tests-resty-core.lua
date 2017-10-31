
local string = require "resty.string"

describe("resty.core", function()
    --
    it("md5 ", function()
        assert.equal('0cc175b9c0f1b6a831c399e269772661', ngx.md5('a'))
      end)
    
    it("sha1", function()
        --
        assert.equal('86f7e437faa5a7fce15d1ddcb9eaeaea377667b8', string.to_hex(ngx.sha1_bin("a")))
      end)
    
    it("base64", function()
        --
        assert.equal('YQ==', ngx.encode_base64("a"))
        assert.equal('a', ngx.decode_base64(ngx.encode_base64("a")))
      end)
    
    it("uri", function()
        --
        assert.equal(' ', ngx.unescape_uri('%20'))
        assert.equal('%20', ngx.escape_uri(' '))
      end)
end)
