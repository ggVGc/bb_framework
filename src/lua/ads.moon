framework = framework or {}

framework.ads = {
  interstitialDisplayCallback: ->
  interstitialCloseCallback: ->
  --prepareInterstitial:->
    --_c_framework.adPrepareInterstitial!
  showInterstitial: (onClose)->
    print 'FRAMEWORK: SHOWING INTERSTITIAL'
    framework.ads.interstitialDisplayCallback = (success) ->
      print 'FRAMEWORK: INTERSTITIAL DISPLAY CALLBACK, success:'..tostring(success)
      if success
        framework.ads.interstitialCloseCallback = ->
          print 'FRAMEWORK: INTERSTITIAL CLOSE CALLBACK'
          onClose success
      else
        onClose success
    _c_framework.adShowInterstitial!
}

framework.AssetLoader
