#import <UIKit/UIKit.h>

int getScreenRefreshRate(){
  return 60;
}

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

void startProfiler(){
}
void stopProfiler(){
}


int userOwnsProduct(const char *id){
  return 0;
}
void purchaseProduct(const char *id){
  onPurchaseComplete(0);
}
const char* getProductPrice(const char *id){
  return "";
}

int main(int argc, char *argv[]) {
    
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, nil);
        return retVal;
    }
}
