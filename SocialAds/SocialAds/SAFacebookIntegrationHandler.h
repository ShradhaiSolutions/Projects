//
//  SAFacebookIntegrationHandler.h
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 12/30/13.
//  Copyright (c) 2013 Social Ads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAFacebookIntegrationHandler : NSObject

+ (id)sharedInstance;

- (BOOL)handleOpenURL:(NSURL *)url;
- (void)handleAppBecomeActive;
- (void)closeSessionAndClearTokenInformation;

- (NSArray *)retrieveUserEvents;

@end
