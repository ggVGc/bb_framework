framework = framework or {}


framework.DataStore = {
  autoCommit: true
  data: {}
  reload: ->
    s = _c_framework.dataStoreReload!
    if s
      print "Loaded:", s
      f = loadstring(s)
      if f
        d = f!
        framework.DataStore.data = d or {}
      else
        print "WARNING: Failed loading data store!"

  commit: ->
    d, msg= framework.tserialize(framework.DataStore.data)
    if d
      print "Committing:", d
      _c_framework.dataStoreCommit d
    else
      print msg
}

--local autoCommitMt
--autoCommitMt = {
  --__newindex: (obj, key, val)->
    --rawset(obj, key, val)
    --if type(val) == 'table'
      --setmetatable val, autoCommitMt
    --if framework.DataStore.autoCommit
      --print "Commiting data store"
      --framework.DataStore.commit!
--}

mt = {
  __index: (obj, key)->
    framework.DataStore.data[key]

  __newindex: (obj, key, val)->
    framework.DataStore.data[key] = val
    --if type(val) == 'table'
      --setmetatable val, autoCommitMt
    if framework.DataStore.autoCommit
      print "Commiting data store"
      framework.DataStore.commit!
}

setmetatable framework.DataStore, mt

framework.DataStore
