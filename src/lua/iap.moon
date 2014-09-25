

framework.IAP = {
  callbacks: {}
  userOwnsProduct: (id) ->
    _c_framework.userOwnsProduct id

  purchaseProduct: (id, callback) ->
    print 'purchasing product: '..tostring(id)
    framework.IAP.callbacks[id] = callback
    _c_framework.purchaseProduct id

  onPurchaseComplete: (id, success)->
    print 'purchase complete: '..tostring(success)
    c = framework.IAP.callbacks[id]
    c and c(success, id)
    framework.IAP.callbacks[id] = nil
}

framework.IAP
