//
//  SADataManager.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 3/18/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SADataManager.h"
#import "SADataCommunicator.h"
#import "SADataParser.h"

@interface SADataManager ()

@property (strong, nonatomic) SADataCommunicator *communicator;

@end

@implementation SADataManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static SADataManager *sharedManagerInstance;
    dispatch_once(&once, ^ {
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _communicator = [[SADataCommunicator alloc] init];
    }
    return self;
}

- (void)fetchData
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    [[self fetchPropertyMetaData] subscribeNext:^(id x) {
        LogDebug(@"Next Value: %@", x);
        self.events = x;
    } error:^(NSError *error) {
        LogError(@"Error: %@", error);
    } completed:^{
        LogInfo(@"Remote Data Import is Completed!!!");
    }];
}

#pragma mark - Fetch Events Data
- (RACSignal *)fetchPropertyMetaData
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[self.communicator fetchEventsData]
            flattenMap:^RACStream *(id responseData) {
                LogDebug(@"Events response is received");
                SADataParser *parser = [[SADataParser alloc] init];
                return [parser parseEventsInformation:responseData];
            }];
    
}

@end
