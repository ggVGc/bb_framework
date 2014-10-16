framework = framework or {}

noop = ->


interstitialCounter = 0

framework.Ads = {
  interstitialInterval: 2
  enabled: true
  interstitialDisplayCallback: noop
  interstitialCloseCallback: noop
  --prepareInterstitial:->
    --_c_framework.adPrepareInterstitial!
  showInterstitial: (onClose)->
    interstitialCounter+=1
    if not framework.Ads.enabled or interstitialCounter <framework.Ads.interstitialInterval
      onClose false if onClose
    else
      print 'FRAMEWORK: SHOWING INTERSTITIAL'
      interstitialCounter = 0
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
