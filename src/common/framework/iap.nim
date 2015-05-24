when not defined(IAP_H_E25DMUWI): 
  const 
    IAP_H_E25DMUWI* = true
  proc userOwnsProduct*(id: cstring): cint {.importc: "userOwnsProduct", 
      header: "iap.h".}
  proc purchaseProduct*(id: cstring) {.importc: "purchaseProduct", 
                                       header: "iap.h".}
  proc getProductPrice*(id: cstring): cstring {.importc: "getProductPrice", 
      header: "iap.h".}
  proc onPurchaseComplete*(success: cint) {.importc: "onPurchaseComplete", 
      header: "iap.h".}
  proc iapCanRestorePurchases*(): cint {.importc: "iapCanRestorePurchases", 
      header: "iap.h".}
  proc iapRestorePurchases*() {.importc: "iapRestorePurchases", header: "iap.h".}
  proc iapAvailable*(): cint {.importc: "iapAvailable", header: "iap.h".}

