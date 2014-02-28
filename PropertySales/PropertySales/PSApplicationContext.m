//
//  PSApplicationContext.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/27/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSApplicationContext.h"

static NSString * const kLastSuccessfulDataFetch = @"lastSuccessfulDataFetch";
static NSString * const kDataRefreshInterval = @"dataRefreshInterval";

@interface PSApplicationContext ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSNumber *refreshInterval;

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

#pragma mark - Last Successful Data Fetch Timestamp
- (NSDate *)lastSuccessfulDataFetchTimestamp
{
    return [self.userDefaults objectForKey:kLastSuccessfulDataFetch];
}

- (void)saveSuccessfulDataFetchTimestamp
{
    [self.userDefaults setObject:[NSDate date] forKey:kLastSuccessfulDataFetch];
    [self.userDefaults synchronize];
}

#pragma mark - Data Refresh Interval
- (NSUInteger)refreshIntervalInSeconds
{
    NSNumber *interval = [self refreshInterval];
    NSUInteger intervalInSeconds;
    
    if(interval == nil) {
        //4 hours = 4 * 60 minutes = 4 * 60 * 60 seconds
        intervalInSeconds = 4 * 60 * 60;
        
        [self updateRefreshInterval:@(intervalInSeconds)];
    } else {
        intervalInSeconds = [interval longValue];
    }
    
    return intervalInSeconds;
}

- (NSNumber *)refreshInterval
{
    return [self.userDefaults objectForKey:kDataRefreshInterval];
}

- (void)updateRefreshInterval:(NSNumber *)intervalInSeconds
{
    [self.userDefaults setObject:intervalInSeconds forKey:kDataRefreshInterval];
    [self.userDefaults synchronize];
}

@end
