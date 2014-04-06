//
//  SAAppDelegate.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 12/26/13.
//  Copyright (c) 2013 Social Ads. All rights reserved.
//

#import "SAAppDelegate.h"
#import "SAFacebookIntegrationHandler.h"

#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#import <Crashlytics/Crashlytics.h>
#import <CrashlyticsLumberjack/CrashlyticsLogger.h>

@interface SAAppDelegate ()

@end

@implementation SAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //DDLogger must be configured before setting the rootViewController
    [self setupLoggerFramework];
    
//    [Crashlytics startWithAPIKey:@"fae00db142eb503989a6c199d8a844b24463151f"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SignIn" bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    
    return YES;
}
    
- (void) setupLoggerFramework
{
    //CocoaLumberjack Log framework integration
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    //Crashlytics Logger
//    [DDLog addLogger:[CrashlyticsLogger sharedInstance]];
    
#ifdef DEBUG
    // And we also enable colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    UIColor *gray = [UIColor darkGrayColor];
    UIColor *blue = [UIColor colorWithRed:(32/255.0) green:(32/255.0) blue:(192/255.0) alpha:1.0];
    UIColor *green = [UIColor colorWithRed:(32/255.0) green:(192/255.0) blue:(32/255.0) alpha:1.0];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[SAFacebookIntegrationHandler sharedInstance] handleAppBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [[SAFacebookIntegrationHandler sharedInstance] handleOpenURL:url];
}

@end
