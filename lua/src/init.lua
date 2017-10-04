

-- preload common modules
require "resty.core" -- see https://github.com/openresty/lua-resty-core

-- core class extension
require('luacat.luacat.luacat') -- 注意: luacat 库自带的 moacat 是一个做游戏的 sdk, 没有使用，但是也没有删除

-- mount everyday use modules to global
_G.JSON = require('libcjson.libcjson')
_G.utils = require('yqj.utils')(ngx)
_G.utils.regex = require('regex.regex')

-- lua lodash
_G._ = require('moses.moses_min')

-- just to collect any garbage
collectgarbage("collect")
