//
//  SAFacebookIntegrationHandler.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 12/30/13.
//  Copyright (c) 2013 Social Ads. All rights reserved.
//

#import "SAFacebookIntegrationHandler.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation SAFacebookIntegrationHandler

+ (id)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// Override application:openURL:sourceApplication:annotation to call the FBsession object that handles the incoming URL
- (BOOL)handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)handleAppBecomeActive
{
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

- (void) closeSessionAndClearTokenInformation
{
    // Close the session and remove the access token from the cache
    // The session state handler (in the app delegate) will be called automatically
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (NSArray *)retrieveUserEvents
{
    __block NSArray *userEvents = [NSArray array];
    
    [FBRequestConnection startWithGraphPath:@"/me/events"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSLog(@"UserEvents: %@", result);
                                  
                                  userEvents = (NSArray *) result;
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  [self handleError:error];
                              }
                          }];

    return userEvents;

}

- (void) handleError:(NSError *)error
{
    //Get more error information from the error
    NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
    
    NSLog(@"%s: ErrorMessage: %@",__PRETTY_FUNCTION__, [errorInformation objectForKey:@"message"]);
}

@end
