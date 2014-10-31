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

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet frameworkViewController *viewController;

@end

