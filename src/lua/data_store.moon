framework = framework or {}


framework.DataStore = {
  autoCommit: true
  data: {}
  reload: ->
    print 'reloading'
    s = _c_framework.dataStoreReload!
    if s
      print s
      d = loadstring(s)()
      framework.DataStore.data = d or {}

  commit: ->
    print 'commiting'
    d = framework.tserialize(framework.DataStore.data)
    print d
    _c_framework.dataStoreCommit d
}


mt = {
  __index: (obj, key)->
    v = framework.DataStore.data[key]
    if v
      return v

  __newindex: (obj, key, val)->
    framework.DataStore.data[key] = val
    if framework.DataStore.autoCommit
      framework.DataStore.commit!
}

setmetatable framework.DataStore, mt

framework.DataStore
