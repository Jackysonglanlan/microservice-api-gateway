

-- preload common modules
require "resty.core" -- see https://github.com/openresty/lua-resty-core

-- mount everyday use modules to global
_G.JSON = require('cjson')
_G.utils = require('yqj.utils')(ngx)
_G.utils.regex = require('regex.regex')
_G._ = require('moses.moses_min') -- lua's lodash

-- just to collect any garbage
collectgarbage("collect")
