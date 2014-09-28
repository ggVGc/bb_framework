framework = framework or {}

framework.Ads = {
  enabled: true
  interstitialDisplayCallback: ->
  interstitialCloseCallback: ->
  --prepareInterstitial:->
    --_c_framework.adPrepareInterstitial!
  showInterstitial: (onClose)->
    if not framework.Ads.enabled
      onClose false
    else
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

  setBannersEnabled: (e)->
    _c_framework.adSetBannersEnabled(e and 1 or 0)

  setEnabled: (e)->
    framework.Ads.enabled = e
    framework.Ads.setBannersEnabled e
}

framework.Ads
