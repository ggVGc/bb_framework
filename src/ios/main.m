#import <UIKit/UIKit.h>
#import <Chartboost/Chartboost.h>
#import "app.h"
#import "iap.h"
#import "ads.h"
#import "util.h"

int getScreenRefreshRate(){
  return 60;
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
