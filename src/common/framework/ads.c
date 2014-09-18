#include "util.h"
#include "ads.h"

void adShowInterstitial(){
  trace("showInterstitial");
  adInterstitialDisplayed(1);
  adInterstitialClosed();
}

void adPrepareInterstitial(){
  trace("prepareInterstitial");
}
