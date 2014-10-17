//
//  frameworkAppDelegate.m
//  framework
//
//  Created by Walt on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "frameworkAppDelegate.h"
#import "frameworkViewController.h"

@implementation frameworkAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.viewController;

    /*
    CGRect screenBounds = [[UIScreen mainScreen] bounds];    
    self.glView = [[[EAGLView alloc] initWithFrame:screenBounds] autorelease];
    [self.window addSubview:_glView];
    [self.window makeKeyAndVisible];
    */
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.viewController stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
    [viewController release];
    [window release];
    
    [super dealloc];
}

@end
