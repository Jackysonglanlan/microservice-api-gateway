

-- http://localhost:7777/demo-lua-script

--[[
 private
 --]]

function print( ... )
  ngx.say("<p style='color:red'>")
  for k, v in pairs({...}) do
    ngx.say(v)
  end
  ngx.say("</p>")
end


--[[
 test
 --]]

print("Inside a lua script!!!")

local resty_sha1 = require "resty.sha1"

local sha1 = resty_sha1:new()
if not sha1 then
  print("failed to create the sha1 object")
  return
end

local ok = sha1:update("hello, ")
if not ok then
  print("failed to add data")
  return
end

ok = sha1:update("world")
if not ok then
  print("failed to add data")
  return
end

local digest = sha1:final()  -- binary digest

local str = require "resty.string"
print("sha1: " .. str.to_hex(digest))
-- output: "sha1: b7e23ec29af22b0b4e41da31e868d57226121c84"

local resty_md5 = require "resty.md5"
local md5 = resty_md5:new()
if not md5 then
  print("failed to create md5 object")
  return
end

local ok = md5:update("hel")
if not ok then
  print("failed to add data")
  return
end

ok = md5:update("lo")
if not ok then
  print("failed to add data")
  return
end

local digest = md5:final()

local str = require "resty.string"
print("md5: ", str.to_hex(digest))
-- yield "md5: 5d41402abc4b2a76b9719d911017c592"

local resty_sha224 = require "resty.sha224"
local str = require "resty.string"
local sha224 = resty_sha224:new()
print(sha224:update("hello"))
local digest = sha224:final()
print("sha224: ", str.to_hex(digest))

local resty_sha256 = require "resty.sha256"
local str = require "resty.string"
local sha256 = resty_sha256:new()
print(sha256:update("hello"))
local digest = sha256:final()
print("sha256: ", str.to_hex(digest))

local resty_sha512 = require "resty.sha512"
local str = require "resty.string"
local sha512 = resty_sha512:new()
print(sha512:update("hello"))
local digest = sha512:final()
print("sha512: ", str.to_hex(digest))

local resty_sha384 = require "resty.sha384"
local str = require "resty.string"
local sha384 = resty_sha384:new()
print(sha384:update("hel"))
print(sha384:update("lo"))
local digest = sha384:final()
print("sha384: ", str.to_hex(digest))

local resty_random = require "resty.random"
local str = require "resty.string"
local random = resty_random.bytes(16)
-- generate 16 bytes of pseudo-random data
print("pseudo-random: ", str.to_hex(random))

local resty_random = require "resty.random"
local str = require "resty.string"
local strong_random = resty_random.bytes(16, true)
-- attempt to generate 16 bytes of
-- cryptographically strong random data
while strong_random == nil do
  strong_random = resty_random.bytes(16, true)
end
print("random: ", str.to_hex(strong_random))

local aes = require "resty.aes"
local str = require "resty.string"
local aes_128_cbc_md5 = aes:new("AKeyForAES")
-- the default cipher is AES 128 CBC with 1 round of MD5
-- for the key and a nil salt
local encrypted = aes_128_cbc_md5:encrypt("Secret message!")
print("AES 128 CBC (MD5) Encrypted HEX: ", str.to_hex(encrypted))
print("AES 128 CBC (MD5) Decrypted: ", aes_128_cbc_md5:decrypt(encrypted))

local aes = require "resty.aes"
local str = require "resty.string"
local aes_256_cbc_sha512x5 = aes:new("AKeyForAES-256-CBC", 
"MySalt!!", aes.cipher(256, "cbc"), aes.hash.sha512, 5)
-- AES 256 CBC with 5 rounds of SHA-512 for the key
-- and a salt of "MySalt!!"
-- Note: salt can be either nil or exactly 8 characters long
local encrypted = aes_256_cbc_sha512x5:encrypt("Really secret message!")
print("AES 256 CBC (SHA-512, salted) Encrypted HEX: ", str.to_hex(encrypted))
print("AES 256 CBC (SHA-512, salted) Decrypted: ", 
aes_256_cbc_sha512x5:decrypt(encrypted))

local aes = require "resty.aes"
local str = require "resty.string"
local aes_128_cbc_with_iv = assert(aes:new("1234567890123456", 
nil, aes.cipher(128, "cbc"), {iv = "1234567890123456"}))
-- AES 128 CBC with IV and no SALT
local encrypted = aes_128_cbc_with_iv:encrypt("Really secret message!")
print("AES 128 CBC (WITH IV) Encrypted HEX: ", str.to_hex(encrypted))
print("AES 128 CBC (WITH IV) Decrypted: ", 
aes_128_cbc_with_iv:decrypt(encrypted))
