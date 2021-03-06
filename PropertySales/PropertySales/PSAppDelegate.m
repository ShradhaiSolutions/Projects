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

#import <Crashlytics/Crashlytics.h>
#import <CrashlyticsLumberjack/CrashlyticsLogger.h>

#import "PSTestViewController.h"
#import "PSApplicationContext.h"
#import "PSDataManager.h"

static NSString * const kCrashlyticsAPIKey = @"CrashlyticsAPIKey";
static NSString * const kGoogleAnalyticsTrackingId = @"GoogleAnalyticsTrackingId";

@interface PSAppDelegate ()

@property (strong, nonatomic) id<GAITracker> analytics;

@end

@implementation PSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //Setup Magical Record
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"PropertySales"];
    
    //DDLogger must be configured before setting the rootViewController
    [self setupLoggerFramework];
    
    [Crashlytics startWithAPIKey:[[[PSApplicationContext sharedInstance] appKeys] objectForKey:kCrashlyticsAPIKey]];
    
    [self setupGoogleAnalytics];

    //Set the RootViewController after integrating all the frameworks
//    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"PSTestStoryboard"
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"PropertySales"
                                                                bundle:nil]
                                      instantiateInitialViewController];

    return YES;
}

- (void)setupGoogleAnalytics
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    //To set the DryRun mode (send the analytics data to Google or Not)
    [[GAI sharedInstance] setDryRun:NO];
    
#ifdef DEBUG
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
#else
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
#endif
    
    // Initialize tracker.
    self.analytics = [[GAI sharedInstance] trackerWithTrackingId:[[[PSApplicationContext sharedInstance] appKeys] objectForKey:kGoogleAnalyticsTrackingId]];
}

- (void) setupLoggerFramework
{
    //CocoaLumberjack Log framework integration
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    //Crashlytics Logger
    [DDLog addLogger:[CrashlyticsLogger sharedInstance]];
    
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
    
    //To refresh the data
    [[PSDataManager sharedInstance] fetchData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [MagicalRecord cleanUp];
}

#pragma mark - Custom URL Scheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    LogInfo(@"Source Application: %@, url: %@", sourceApplication, url);
    
    if (url) {
        //Handle the url
    }
    
    return YES;
}


@end
