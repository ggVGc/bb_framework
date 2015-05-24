when not defined(ADS_H_OSH6QJIZ): 
  const 
    ADS_H_OSH6QJIZ* = true
  proc adPrepareInterstitial*() {.importc: "adPrepareInterstitial", 
                                  header: "ads.h".}
  proc adShowInterstitial*() {.importc: "adShowInterstitial", header: "ads.h".}
  proc adInterstitialDisplayed*(success: cint) {.
      importc: "adInterstitialDisplayed", header: "ads.h".}
  proc adInterstitialClosed*() {.importc: "adInterstitialClosed", 
                                 header: "ads.h".}
  proc adSetBannersEnabled*(enable: cint) {.importc: "adSetBannersEnabled", 
      header: "ads.h".}

