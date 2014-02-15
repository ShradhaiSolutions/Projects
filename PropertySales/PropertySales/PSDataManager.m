//
//  PSDataManager.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSDataManager.h"
#import "PSPropertyMetaDataRequest.h"
#import "PSDataCommunicator.h"
#import "PSPropertyMetadataDataParser.h"

@implementation PSDataManager

- (void)fetchData
{
    ENTRY_LOG;
    
    [[self fetchPropertyMetaData] subscribeNext:^(id x) {
        NSDictionary *postParams = x;
        LogVerbose(@"Post Params: %@", postParams);
    }];
    
    EXIT_LOG;
}

- (RACSignal *)fetchPropertyMetaData
{
    ENTRY_LOG;
    
    PSDataCommunicator *communicator = [[PSDataCommunicator alloc] init];
    PSPropertyMetadataDataParser *parser = [[PSPropertyMetadataDataParser alloc] init];
    
    EXIT_LOG;
    
    return [[communicator fetchPropertyMetaData]
            flattenMap:^RACStream *(id responseData) {
                return [parser parsePropertySalesInitialRequest:responseData];
            }];
    
}

@end
