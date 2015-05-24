when not defined(DATA_STORE_H_VI96GFE5): 
  const 
    DATA_STORE_H_VI96GFE5* = true
  proc dataStoreGlobalInit*() {.importc: "dataStoreGlobalInit", 
                                header: "data_store.h".}
  proc dataStoreCommit*(dataString: cstring) {.importc: "dataStoreCommit", 
      header: "data_store.h".}
  proc dataStoreReload*(): cstring {.importc: "dataStoreReload", 
                                     header: "data_store.h".}

