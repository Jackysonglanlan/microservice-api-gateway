
local path = {}

--- Join multiple paths with correct number of '/' separators.
-- The first and last subpath will have theirs first and last '/' characters
-- retained.
-- @param ... multiple string arguments to be joined
-- @return ready path
function path.joinPaths(...)
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


return path
