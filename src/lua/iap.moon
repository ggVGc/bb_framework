

framework.IAP = {
  callbacks: {}
  getProductPrice: (id)->
    _c_framework.getProductPrice id
  userOwnsProduct: (id) ->
    _c_framework.userOwnsProduct(id)==1

  purchaseProduct: (id, callback) ->
    print 'purchasing product: '..tostring(id)
    framework.IAP.callbacks[id] = callback
    _c_framework.purchaseProduct id

  onPurchaseComplete: (id, success)->
    print 'purchase complete: '..tostring(success)
    c = framework.IAP.callbacks[id]
    c and c(success==1, id)
    framework.IAP.callbacks[id] = nil
}

framework.IAP
