framework = framework or {}


framework.DataStore = {
  autoCommit: true
  data: {}
  reload: ->
    s = _c_framework.dataStoreReload!
    if s
      d = loadstring(s)()
      framework.DataStore.data = d or {}

  commit: ->
    d = framework.tserialize(framework.DataStore.data)
    _c_framework.dataStoreCommit d
}

local autoCommitMt
autoCommitMt = {
  __newindex: (obj, key, val)->
    rawset(obj, key, val)
    if type(val) == 'table'
      setmetatable val, autoCommitMt
    if framework.DataStore.autoCommit
      print "Commiting data store"
      framework.DataStore.commit!
}

mt = {
  __index: (obj, key)->
    v = framework.DataStore.data[key]
    if v
      return v

  __newindex: (obj, key, val)->
    framework.DataStore.data[key] = val
    if type(val) == 'table'
      setmetatable val, autoCommitMt
    if framework.DataStore.autoCommit
      print "Commiting data store"
      framework.DataStore.commit!
}

setmetatable framework.DataStore, mt

framework.DataStore
