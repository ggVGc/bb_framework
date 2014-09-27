

framework.IAP = {
  callback: nil
  getProductPrice: (id)->
    _c_framework.getProductPrice id
  userOwnsProduct: (id) ->
    _c_framework.userOwnsProduct(id)==1

  purchaseProduct: (id, callback) ->
    print 'purchasing product: '..tostring(id)
    framework.IAP.callback = callback
    _c_framework.purchaseProduct id

  onPurchaseComplete: (success)->
    print 'purchase complete: '..tostring(success)
    c = framework.IAP.callback
    c and c(success==1)
    framework.IAP.callback = nil
}

framework.IAP
