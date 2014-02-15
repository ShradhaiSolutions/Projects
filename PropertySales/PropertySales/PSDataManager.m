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
#import "PSPropertySaleDataParser.h"

@interface PSDataManager ()

@property (strong, nonatomic) PSDataCommunicator *communicator;

@property (strong, nonatomic) NSDictionary *postParams;
@property (strong, nonatomic) NSArray *saleDates;

@end


@implementation PSDataManager

- (id)init
{
    self = [super init];
    if (self) {
        _communicator = [[PSDataCommunicator alloc] init];
    }
    return self;
}

- (void)fetchData
{
    ENTRY_LOG;
    
    NSDate *methodStart = [NSDate date];
    
//    [[self fetchPropertyMetaData]
//     subscribeNext:^(id x) {
//         self.postParams = x;
//         LogVerbose(@"Post Params: %@", self.postParams);
//     }];
    
    NSMutableArray *properties = [NSMutableArray array];
    
    [[[self fetchPropertyMetaData]
     flattenMap:^RACStream *(id value) {
         LogVerbose(@"Parsed Metadata: %@", value);
         
         return [self fetchPropertySalesWithPasedMetadata:value];
     }] subscribeNext:^(id x) {
//         LogDebug(@"Next Value: %@", x);
         [properties addObjectsFromArray:x];
         LogInfo(@"Next Value is received");
     } error:^(NSError *error) {
         LogError(@"Error While execution: %@", error);
         
         NSDate *methodFinish = [NSDate date];
         NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
         LogInfo(@"executionTime in seconds = %f", executionTime);
     } completed:^{
         LogInfo(@"Completed!!!. Total Number of Properties: %lu", [properties count]);
         
         NSDate *methodFinish = [NSDate date];
         NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
         LogInfo(@"executionTime in seconds = %f", executionTime);
     }];
    
    EXIT_LOG;
}

- (RACSignal *)fetchPropertyMetaData
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[self.communicator fetchPropertyMetaData]
            flattenMap:^RACStream *(id responseData) {
                PSPropertyMetadataDataParser *parser = [[PSPropertyMetadataDataParser alloc] init];
                return [parser parsePropertySalesInitialRequest:responseData];
            }];
    
}

- (RACSignal *)fetchPropertySalesWithPasedMetadata:(NSDictionary *)parsedData
{
    ENTRY_LOG;
    
    NSArray *saleDates =  [parsedData objectForKey:@"SaleDatesArray"];
    LogInfo(@"SaleDates: %@", saleDates);
    
    if([saleDates count] > 0) {
        NSMutableDictionary *saleDatePostParams = [parsedData mutableCopy];
        [saleDatePostParams removeObjectForKey:@"SaleDatesArray"];
        
        NSMutableArray *saleDateSignals = [NSMutableArray array];
        
        for(NSString *saleDate in saleDates) {
            NSMutableDictionary *postParams = [saleDatePostParams mutableCopy];
            
            LogInfo(@"Fetching the properties for the sale date: %@", saleDate);
            [postParams setObject:saleDate forKey:@"ddlDate"];
            
            [saleDateSignals addObject:[self fetchPropertySaleDataWithPostParams:[postParams copy]]];
        }
        
        return [RACSignal merge:saleDateSignals];
    } else {
        LogError(@"SaleDate array is empty");
        return [RACSignal empty];
    }
    
    EXIT_LOG;
}

- (RACSignal *)fetchPropertySalesWithPasedMetadata1:(NSDictionary *)parsedData
{
    ENTRY_LOG;
    
    NSArray *saleDates =  [parsedData objectForKey:@"SaleDatesArray"];
    LogInfo(@"SaleDates: %@", saleDates);
    
    if([saleDates count] > 0) {
        NSString *saleDate = saleDates[0];
        
        NSMutableDictionary *saleDate1PostParams = [parsedData mutableCopy];
        [saleDate1PostParams removeObjectForKey:@"SaleDatesArray"];
        
        LogInfo(@"Fetching the properties for the sale datea: %@", saleDate);
        [saleDate1PostParams setObject:saleDate forKey:@"ddlDate"];
        
        return [self fetchPropertySaleDataWithPostParams:[saleDate1PostParams copy]];
    } else {
        LogError(@"SaleDate array is empty");
        return [RACSignal empty];
    }
    
    EXIT_LOG;
}


- (RACSignal *)fetchPropertySaleDataWithPostParams:(NSDictionary *)postParams
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[self.communicator fetchPropertySaleDataWithPostParams:postParams]
            flattenMap:^RACStream *(id responseData) {
                PSPropertySaleDataParser *parser = [[PSPropertySaleDataParser alloc] init];
                return [parser parsePropertySalesInformation:responseData];
            }];
    
}

@end
