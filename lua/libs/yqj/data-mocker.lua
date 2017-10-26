local gene = {}

--- Generate randomized table based on provided template.
-- @t A template in table format. Keys are constant and should have string
-- type. Their values may be list of strings or just strings. The latter will
-- be split using "," as delimiter. Eventually instead of list/string a
-- function can be given. It should return a (supposedly random) value or list
-- of possible values to chosen randomly.
-- @return randomized table
function gene.rand_table(t)
  assert(type(t) == "table", "t must be a table!")
  
  local randtab = {}
  for k, v in pairs(t) do
    -- check keys, values (or generate them)
    assert(type(k) == "string", "key within t must have a string type!")
    -- value can be a string, then try split it using a "," as delimiter
    if type(v) == "string" then
      local values = {}
      -- split, trim and insert values into list
      string.gsub(v, '([^,]+)', function(s) table.insert(values, string.match(s, '%s-(%S+)%s-')) end)
      v = values
    elseif type(v) == "function" then
      v = v()
      -- enclose returned value in a table for code below to work correctly
      if type(v) ~= "table" then v = {v} end
    end
    
    assert(type(v) == "table", "could not find or generate value table within t!")
    
    -- put randomly chosen value into table
    randtab[k] = v[math.random(#v)]
  end
  return randtab
end


return gene
