//
//  SADataImporter.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 3/18/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SADataImporter.h"

@implementation SADataImporter

- (RACSignal *)importPropertyData:(NSArray *)propertyData withAddressLookData:(NSDictionary *)addressLookupData
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendCompleted];
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

@end
