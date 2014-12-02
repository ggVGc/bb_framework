#import "frameworkAppDelegate.h"
#import "frameworkViewController.h"
#import "app.h"
#import "framework/util.h"
#import "framework/ads.h"
#import "appConfig.h"
#import "chartboostDelegateImpl.h"
#import <Chartboost/Chartboost.h>
#import "EAGLView.h"

@implementation frameworkAppDelegate

@synthesize window;
@synthesize viewController;

static ChartboostDelegateImpl *cbDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window.rootViewController = self.viewController;
  cbDelegate = [[ChartboostDelegateImpl alloc] init];
  //[Chartboost startWithAppId:AppConfig.cb.appId appSignature:AppConfig.cb.appSignature delegate:cbDelegate];
  [Chartboost startWithAppId:@"545d4d160d602524bc431795" appSignature:@"2924db06cc538c1e10016e889607d88c43378e62"  delegate:cbDelegate];
  cbDelegate->cacheing = true;
  [Chartboost cacheInterstitial:CBLocationDefault];
  return YES;
}

- (void)orientationChanged:(NSNotification *)notification{
  NSLog(@"Orientation Changed");
}
- (void)applicationWillResignActive:(UIApplication *)application {
  NSLog(@"Will resign active");
  EAGLView *v = (EAGLView*)viewController.view;
  [v setPaused:true];
  appSuspend();
  /*
     appUnloadTextures();
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  NSLog(@"Did become active");
  EAGLView *v = (EAGLView*)viewController.view;
  /*
     v->needsReload = true;
     */
  [v setPaused:false];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  NSLog(@"Will terminate");
  //appDeinit();
}

- (void)applicationWillEnterBackground:(UIApplication *)application {
  NSLog(@"Will enter background");
  appSetPaused(1, 1);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  NSLog(@"Will enter foreground");
  appSetPaused(0, 0);
}


void adShowInterstitial(){
  trace("showInterstitial");
  if([Chartboost hasInterstitial:CBLocationDefault]){
    NSLog(@"Showing cached interstitial");
    appSetPaused(1, 0);
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
