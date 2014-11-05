#include "framework/util.h"
#include "framework/ads.h"

void adShowInterstitial(){
  trace("showInterstitial");
  adInterstitialDisplayed(1);
  adInterstitialClosed();
}

void adPrepareInterstitial(){
  trace("prepareInterstitial");
}

void adSetBannersEnabled(int e){
}
