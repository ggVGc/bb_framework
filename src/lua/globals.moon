


export block = (fn)->fn!

export let = (obj, fn)-> fn(obj)
export let = (obj, fn)-> fn(obj)

export make = (fn)->
  o = {}
  let o, fn
  o


export maker = (fn) ->
  (...) ->
    o = {}
    fn(o, ...)
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

--export iterArrs = (...) ->
  --p = {...}
  --paramCount = #p
  --f = p[paramCount]
  --for arrInd=1,paramCount-1
    --a = p[arrInd]
    --for i=1, #a
      --f(a[i], i, a)

--export iterArrsRev = (a, ...) ->
  --argLen = select('#', ...)
  --f = select(argLen, ...)
  --f(a)
  --if argLen > 1
    --iterArrsRev select(2, ...)

export rejectNil = _.bind(fun.filter, fun.op.truth)
