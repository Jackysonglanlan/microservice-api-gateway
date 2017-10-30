-- Copyright (C) 2013 YanChenguang (kedyyan)

local bit = require "bit"
local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C
local bor = bit.bor

local setmetatable = setmetatable
local localtime = ngx.localtime
local ngx = ngx
local type = type


ffi.cdef[[
  int write(int fd, const char * buf, int nbyte);
  int open(const char * path, int access, int mode);
  int close(int fd);
]]

local O_RDWR   = 0x0002
local O_CREAT  = 0x0040
local O_APPEND = 0x0400
local S_IRWXU  = 0x01C0
local S_IRGRP  = 0x0020
local S_IROTH  = 0x0004

local LOG_LEVEL = {debug = 1, info = 2, warn = 3, error = 4, none = 999}

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self, log_type, logfile)
  local log_level, log_fd = nil
  
  local level = LOG_LEVEL[log_type] or LOG_LEVEL['none']
  
  return setmetatable({
    log_level = level, 
    log_fd = C.open(logfile, bor(O_RDWR, O_CREAT, O_APPEND), bor(S_IRWXU, S_IRGRP, S_IROTH)), 
  }, mt)
end


local function _loggerFactory(level)
  return function(self, msg)
    if self.log_level > level then
      return
    end
    local c = localtime() .. ": " .. msg .. "\n";
    C.write(self.log_fd, c, #c);
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



