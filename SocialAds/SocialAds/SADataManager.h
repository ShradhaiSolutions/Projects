//
//  SADataManager.h
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 3/18/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SADataManager : NSObject

@property (strong, nonatomic) NSArray *events;

+ (instancetype)sharedInstance;
- (void)fetchData;

@end
