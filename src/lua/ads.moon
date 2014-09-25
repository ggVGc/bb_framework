framework = framework or {}

framework.Ads = {
  interstitialDisplayCallback: ->
  interstitialCloseCallback: ->
  --prepareInterstitial:->
    --_c_framework.adPrepareInterstitial!
  showInterstitial: (onClose)->
    print 'FRAMEWORK: SHOWING INTERSTITIAL'
    framework.Ads.interstitialDisplayCallback = (success) ->
      print 'FRAMEWORK: INTERSTITIAL DISPLAY CALLBACK, success:'..tostring(success)
      if success
        framework.Ads.interstitialCloseCallback = ->
          print 'FRAMEWORK: INTERSTITIAL CLOSE CALLBACK'
          onClose success
      else
        onClose success
    _c_framework.adShowInterstitial!

  setBannersEnabled: (v)->
    _c_framework.setBannersEnabled(v and 1 or 0)
}

framework.Ads
