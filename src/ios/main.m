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


int main(int argc, char *argv[]) {
    
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, nil);
        return retVal;
    }
}
