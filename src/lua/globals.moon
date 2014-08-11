
export block = (fn)->fn!

export let = (obj, fn)-> fn(obj)

export make = (fn)->
  o = {}
  let o, fn
  o

export maker = (fn) ->
  (...) ->
    args = {...}
    o = {}
    fn(o, unpack(args))
    o

export wrap=(v)->
  ->v

export call=(f)->f!

export compose = (...) ->
  f = {...}
  (...) ->
      local _temp
      for i,fn in pairs(f) do
        if not _.isFunction(fn)
          if _.isArray(fn) and _.isCallable(fn[1])
            fn = _.bindn(fn[1], unpack(_.slice(fn, 2)))
          else
            fn = wrap fn
        if _temp
          _temp = fn(_temp)
        else
          _temp = fn(...)
      _temp

export pipe=(...) -> compose(...)!

export rejectNil = _.bind(fun.filter, fun.op.truth)
