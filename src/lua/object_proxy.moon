framework = framework or {}

mt = {
  __index:(obj, key)->
    if type(key) == 'number'
      return obj[key]
    return nil if #obj<=0 or not obj[1][key]
    --isFunc = type(obj[1][key]) == 'function'
    return (...)->
      for v in *obj
        print 'calling', key
        v[key](...)

  __newindex: (obj, key, value)->
}

framework.ObjectProxy = {
new: (...)=>
  @ = {...}
  setmetatable @, mt
  return @
}


framework.ObjectProxy
