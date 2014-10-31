//
//  frameworkAppDelegate.m
//  framework
//
//  Created by Walt on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "frameworkAppDelegate.h"
#import "frameworkViewController.h"
#import "appConfig.h"
#import "chartboostDelegateImpl.h"
#import <Chartboost/Chartboost.h>

@implementation frameworkAppDelegate

@synthesize window;
@synthesize viewController;

static ChartboostDelegateImpl *cbDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.rootViewController = self.viewController;
    cbDelegate = [[ChartboostDelegateImpl alloc] init];
    [Chartboost startWithAppId:AppConfig.cb.appId appSignature:AppConfig.cb.appSignature delegate:cbDelegate];
    cbDelegate->cacheing = true;
    [Chartboost cacheInterstitial:CBLocationDefault];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  NSLog(@"Will resign active");
  appSetPaused(1);
  appSuspend();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  NSLog(@"Did become active");
  appSetPaused(0);
}

- (void)applicationWillTerminate:(UIApplication *)application {
  NSLog(@"Will terminate");
  //appDeinit();
}

- (void)applicationWillEnterBackground:(UIApplication *)application {
  NSLog(@"Will enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  NSLog(@"Will enter foreground");
}

- (void)dealloc {
    [viewController release];
    [window release];
    
    [super dealloc];
}

void adShowInterstitial(){
  trace("showInterstitial");
  if([Chartboost hasInterstitial:CBLocationDefault]){
    NSLog(@"Showing cached interstitial");
    appSetPaused(1);
    [Chartboost showInterstitial:CBLocationDefault];
  }else{
    NSLog(@"Tried showing interstitial, but none cached. Cacheing new");
    cbDelegate->cacheing = true;
    [Chartboost cacheInterstitial:CBLocationDefault];
    adInterstitialDisplayed(0);
  }
}

void adPrepareInterstitial(){
  trace("prepareInterstitial");
}

void adSetBannersEnabled(int e){
}


@end
