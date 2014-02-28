//
//  PSApplicationContext.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/27/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSApplicationContext.h"


static NSString * const kLastSuccessfulDataFetch = @"lastSuccessfulDataFetch";

@interface PSApplicationContext ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation PSApplicationContext

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PSApplicationContext *sharedManagerInstance;
    dispatch_once(&once, ^ {
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
        
        _appVersionNumber = infoDictionary[@"CFBundleShortVersionString"];
        _buildNumber = infoDictionary[(NSString *)kCFBundleVersionKey];
        _userDefaults = [NSUserDefaults standardUserDefaults];

    }
    return self;
}

- (NSDate *)lastSuccessfulDataFetchTimestamp
{
    return [self.userDefaults objectForKey:kLastSuccessfulDataFetch];
}

- (void)saveSuccessfulDataFetchTimestamp
{
    [self.userDefaults setObject:[NSDate date] forKey:kLastSuccessfulDataFetch];
    [self.userDefaults synchronize];
}

@end
