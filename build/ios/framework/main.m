//
//  main.m
//  framework
//
//  Created by Walt on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



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
