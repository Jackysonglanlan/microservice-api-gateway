
local function _compressJSONStr(jsonStr)
  utils.log(jsonStr)
  return jsonStr
end

local function _decompressJSONStr(compressedStr)
  utils.log(compressedStr)
  return compressedStr
end

local function configRouter(router)
  
  -- _location_/_ops-cache/cache/123
  router:get('/cache/:uid', function(params)
      local function callback(uid)
        -- this only runs *once* until the key expires, so
        -- do expansive operations like connecting to a remote
        -- backend here. i.e: call a backend server or redis in this callback
        local now = Date()
        return JSON.encode({name = uid .. '-' .. now:fmt('${http}')}) -- simulate cache refresh
      end
      
      callbackWithCompress = function(...)
        return _compressJSONStr(callback(...))
      end
      
      -- this call will respectively hit L1 and L2 before running the
      -- callback (L3). The returned value will then be stored in L2 and
      -- L1 for the next request.
      local userInfoJSON, err = cache:get("cache_key_uid", nil, callbackWithCompress, params.uid)
      if err then
        utils.elog('err reading cache value with params:', params)
        userInfoJSON = callbackWithCompress(params.uid) -- query backend server for data
      end
      
      ngx.say(_decompressJSONStr(userInfoJSON))
  end)
end


return configRouter
