framework = framework or {}

noop = ->



framework.Ads = {
  interstitialInterval: 3
  enabled: true
  interstitialDisplayCallback: noop
  interstitialCloseCallback: noop
  --prepareInterstitial:->
    --_c_framework.adPrepareInterstitial!
  showInterstitial: (onClose)->
    if not framework.DataStore.interstitialCounter
      framework.DataStore.interstitialCounter = 0
      framework.DataStore.commit!
    else
      framework.DataStore.interstitialCounter+=1
    if not framework.Ads.enabled or framework.DataStore.interstitialCounter <framework.Ads.interstitialInterval
      onClose false if onClose
    else
      print 'FRAMEWORK: SHOWING INTERSTITIAL'
      framework.DataStore.interstitialCounter = 0
      framework.Ads.interstitialDisplayCallback = (success) ->
        print 'FRAMEWORK: INTERSTITIAL DISPLAY CALLBACK, success:'..tostring(success)
        if success
          framework.Ads.interstitialCloseCallback = ->
            print 'FRAMEWORK: INTERSTITIAL CLOSE CALLBACK'
            onClose success if onClose
        else
          onClose success if onClose
        framework.Ads.interstitialDisplayCallback = noop
      _c_framework.adShowInterstitial!

  --setBannersEnabled: (e)->
    --_c_framework.adSetBannersEnabled(e and 1 or 0)

  setEnabled: (e)->
    framework.Ads.enabled = e
    --framework.Ads.setBannersEnabled e
}

framework.Ads
