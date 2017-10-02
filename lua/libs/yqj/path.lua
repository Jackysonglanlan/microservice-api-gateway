
local path = {}

--- Join multiple paths with correct number of '/' separators.
-- The first and last subpath will have theirs first and last '/' characters
-- retained.
-- @param ... multiple string arguments to be joined
-- @return ready path
function utils.joinPaths(...)
  local last = select("#", ...)
  assert(last > 0, "got no argument to join!")
  local paths = {}

  if last == 1 then return select(1, ...) end

  for idx = 1, last do
    -- don't trim prefix '/' of the first path
    if idx ~= 1 then
      paths[idx] = string.gsub(select(idx, ...), "^/+", "")
    end
    -- don't trim postfix '/' of the last path
    if idx ~= last then
      paths[idx] = string.gsub(select(idx, ...), "/+$", "")
    end
  end
  return table.concat(paths, "/")
end


--- Iterates over files located in path specified directory. Global like characters "*" and "?" supported. They should be entered in file name part and will be used only when matching file names only (don't have any effect on directories). This is shell based version.
-- @param path a path to a directory
-- @param options there actually two additional supported options (case insensitive):
--                "r" - list recursively
--                "i" - returns a table containing detailed file information
-- @return iterator returning filenames in arbitrary order
local function path.listDirShell(path, options)
  assert(type(path) == "string", "path must be a string!")
  options = options or ""
  assert(type(options) == "string", "mode must be a string when specified!")

  -- check if a table with detailed file info has to returned
  local fullinfo = string.match(options, "[iI]") and true or false
  -- check if directory listing has to work recursively
  local recursively = string.match(options, "[rR]") and true or false
  local globpat

  -- Check if there are global ("*" and "?") characters in a path?
  do
    -- split path into two parts where the latter is the last
    local p, lastpart = string.match(path, '^(.-)([^/]+)$')
    -- Check if there was a lone name specified it wasn't a directory.
    if (p == nil or #p == 0 or p == "./") and filename_type(path) == "d" then
      p = path
      lastpart = nil
    end
    -- it's enough to have lastpart only to consider it as glob pattern
    if lastpart then
      -- substitute glob character to pattern ones
      globpat = string.gsub(lastpart, '.', function(c)
        if c == "*" then return '.-'
        elseif c == '?' then return '.'
        else return escape_magic_chars(c) end
      end)
      -- pattern should be anchored for both sides
      globpat = "^" .. globpat .. "$"
      -- effectively trim path from the last part being used as glob
      path = p
    end
  end

  return coroutine.wrap(function()
    -- As Lua doesn't have library options for that use shell one.
    local dirio = io.popen("ls -l --time-style=long-iso " .. (recursively and "-R " or "") .. path)
    if dirio then
      -- Assume that if dirname in ls output will not be found then just use
      -- starting path.
      local dirname = path
      for line in dirio:lines() do
        -- Try to match current ls directory path but only if in recursive
        -- mode.
        if recursively then
          dirname = string.match(line, '^([./]?.*):$') or dirname
        end
        -- try to match an output of "ls" command
        local mode, hardlinks, user, group, size, date, time, filename = string.match(line, '^([-d][r-][w-][x-][r-][w-][x-][r-][w-][x-])%s+(%d+)%s+([^%s]+)%s+([^%s]+)%s+(%d+)%s([^%s]+)%s+([^%s]+)%s+(.+)$')
        if mode then
          local isdir = string.match(mode, "^d") and true or false
          local fileinfo = {mode = mode, hardlinks = hardlinks, user = user, group = group,
                                size = size, date = date, time = time, filename = filename,
                                isdir = isdir, dirname = dirname}
          -- Directories should be omitted as well as filenames what don't fit
          -- a glob pattern (if specified).
          if not isdir and (not globpat or string.match(filename, globpat)) then
            if fullinfo then
              coroutine.yield(fileinfo)
            else
              coroutine.yield(join_paths(dirname, filename))
            end
          end
        end
      end
    end
  end)
end


return path
