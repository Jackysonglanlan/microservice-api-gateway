-- Copyright (C) 2013 YanChenguang (kedyyan)

local ffi = require "ffi"
ffi.cdef[[
  int open(const char * path, int access);
  int write(int fd, const char * buf, int nbyte);
  int close(int fd);
]]
local C = ffi.C
local write = C.write
local open = C.open

local bit = require("bit")
local bor = bit.bor
local setmetatable = setmetatable
local type = type

local O_RDWR   = 0x0002
local O_CREAT  = 0x0040
local O_APPEND = 0x0400

local LOG_LEVEL = {debug = 1, info = 2, warn = 3, error = 4, none = 999}

local os = require('os')
local runningEnv = os.getenv("LUA_ENV") or ''

-- output to console if we are in dev Env.
if string.match(runningEnv, 'dev.*') then
  write = function(_, msg, _)
    os.execute('echo "' .. msg ..'"')
  end
end

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self, ngx, log_type, logfile)
  local log_level, log_fd = nil
  
  local level = LOG_LEVEL[log_type] or LOG_LEVEL['none']
  
  return setmetatable({
    ngx = ngx, 
    log_level = level, 
    log_fd = open(logfile, bor(O_RDWR, O_CREAT, O_APPEND)), 
  }, mt)
end

local function _loggerFactory(level)
  return function(self,  msg)
    if self.log_level > level then
      return
    end
    local msg = self.ngx.localtime() .. ": " .. msg .. "\n";
    write(self.log_fd, msg, #msg);
  end
end

--
-- method defs
--
debug = _loggerFactory(LOG_LEVEL['debug'])
info = _loggerFactory(LOG_LEVEL['info'])
warn = _loggerFactory(LOG_LEVEL['warn'])
error = _loggerFactory(LOG_LEVEL['error'])

local class_mt = {
  -- to prevent use of casual module global variables
  __newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '"')
  end
}

setmetatable(_M, class_mt)
