//
//  PSAppDelegate.m
//  PropertySales
//
//  Created by Dhana Prakash Muddineti on 2/1/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSAppDelegate.h"

#import "DDASLLogger.h"
#import "DDTTYLogger.h"

@implementation PSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setupLoggerFramework];
    
    return YES;
}

- (void) setupLoggerFramework
{
    //CocoaLumberjack Log framework integration
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // And we also enable colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
#ifdef DEBUG
    UIColor *gray = [UIColor darkGrayColor];
    UIColor *blue = [UIColor blueColor];
    UIColor *green = [UIColor greenColor];
    UIColor *orange = [UIColor orangeColor];
    UIColor *red = [UIColor redColor];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:gray backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
    [[DDTTYLogger sharedInstance] setForegroundColor:blue backgroundColor:nil forFlag:LOG_FLAG_DEBUG];
    [[DDTTYLogger sharedInstance] setForegroundColor:green backgroundColor:nil forFlag:LOG_FLAG_INFO];
    [[DDTTYLogger sharedInstance] setForegroundColor:orange backgroundColor:nil forFlag:LOG_FLAG_WARN];
    [[DDTTYLogger sharedInstance] setForegroundColor:red backgroundColor:nil forFlag:LOG_FLAG_ERROR];
#endif

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

#pragma mark - TODO: Remove the below commented statements
//    ENTRY_LOG;
//    EXIT_LOG;
//    ERROR_EXIT_LOG;
//    
//    DDLogVerbose(@"%s Verbose ", __PRETTY_FUNCTION__);
//    DDLogDebug(@"%s Debug ", __PRETTY_FUNCTION__);
//    DDLogInfo(@"%s Info ", __PRETTY_FUNCTION__);
//    DDLogWarn(@"%s Warn ", __PRETTY_FUNCTION__);
//    DDLogError(@"%s Error ", __PRETTY_FUNCTION__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
