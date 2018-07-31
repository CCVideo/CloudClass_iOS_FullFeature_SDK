//
//  AppDelegate.m
//  CCClassRoom
//
//  Created by cc on 17/1/18.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "AppDelegate.h"
#import <SDImageCache.h>
#import "SULogger.h"
#import "CCExceptionHandler.h"
#import <Bugly/Bugly.h>
#import <OpenGLES/ES2/gl.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [SDImageCache sharedImageCache].shouldDecompressImages = NO;
    //    [SULogger start];
    BuglyConfig *config = [[BuglyConfig alloc] init];
    config.debugMode = true;
    config.viewControllerTrackingEnable = true;
    
    config.reportLogLevel = BuglyLogLevelWarn;
    [Bugly startWithAppId:@"70f4bb406e" config:config];
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    if (self.shouldNeedLandscape)
    {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    glFinish();
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
