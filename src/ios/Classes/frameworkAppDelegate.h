//
//  frameworkAppDelegate.h
//  framework
//
//  Created by Walt on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Chartboost/Chartboost.h>

@class frameworkViewController;

@interface frameworkAppDelegate : NSObject <UIApplicationDelegate, ChartboostDelegate> {
    UIWindow *window;
    frameworkViewController *viewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet frameworkViewController *viewController;

@end

