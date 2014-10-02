local _ = {}

function _.bind(f,v)
  return function (...)
      return f(v,...)
    end
end


--- Similar to `pairs` iterator. Calls function `f` on each key-value of a given collection. <br/><em>Aliased as `forEach`</em>.
-- @name each
-- @tparam table list a collection
-- @tparam function f an iterator function, prototyped as `f(key,value,...)`
-- @tparam[opt] var_arg ... Optional extra-args to be passed to function `f`
function _.each(list, f, ...)
  if not(type(list)=='table') then return end
  for index,value in pairs(list) do
    f(index,value,...)
  end
end

--- Extends an object properties. It copies all of the properties of extra passed-in objects
-- over to the destination object, and returns the destination object.
-- The last object in `...` will override properties of the same name in the previous one
-- @name extend
-- @tparam table destObj a destination object
-- @tparam var_arg ... a variable number of array arguments
-- @treturn table the destination object extended
function _.extend(destObj,...)
  local sources = {...}
  _.each(sources,function(__,source)
    if type(source)=='table' then
      _.each(source,function(key,value)
        destObj[key] = value
      end)
    end
  end)
  return destObj
end


function _.indexOf(array, value)
  for k = 1,#array do
    if array[k] == value then return k end
  end
end

return _
