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
#import "PSFileManager.h"
#import "PSLocationParser.h"
#import "PSDataImporter.h"

#import "Property.h"
#import "AddressLookup.h"

@interface PSDataManager ()

@property (strong, nonatomic) PSDataCommunicator *communicator;

@property (strong, nonatomic) NSDictionary *postParams;
@property (strong, nonatomic) NSArray *saleDates;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation PSDataManager

- (id)init
{
    self = [super init];
    if (self) {
        _communicator = [[PSDataCommunicator alloc] init];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }
    return self;
}

- (void)fetchData
{
    ENTRY_LOG;
    
//    LogError(@"isMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
    
    NSDate *startTime = [NSDate date];
    
    NSMutableArray *properties = [NSMutableArray array];
    
    [[[[self fetchPropertyMetaData] deliverOn:[RACScheduler scheduler]]
     flattenMap:^RACStream *(id value) {
//         LogError(@"1. isMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
         
         LogVerbose(@"Parsed Metadata: %@", value);
         
         return [self fetchPropertySalesWithPasedMetadata:value];
     }] subscribeNext:^(id x) {
//         LogError(@"2. isMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
//         LogDebug(@"Next Value: %@", x);
         [properties addObjectsFromArray:x];
         LogInfo(@"Next Value is received");
     } error:^(NSError *error) {
         LogError(@"Error While execution: %@", error);
         
         [self logExecutionTime:startTime];
     } completed:^{
//         LogError(@"4. isMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
         LogInfo(@"Completed!!!. Total Number of Properties: %lu", [properties count]);
         
         PSFileManager *fileManager = [[PSFileManager alloc] init];
         [fileManager savePropertiesToFile:properties];
         
         PSLocationParser *locatinParser = [[PSLocationParser alloc] init];
         locatinParser.properties = properties;
         
         [[locatinParser parseAddressesToCoordinates] subscribeNext:^(id x) {
//             LogError(@"5. isMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
             LogInfo(@"Next Value: %@", x);
         } error:^(NSError *error) {
             LogError(@"Error While execution: %@", error);
         } completed:^{
//             LogError(@"6. isMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
             LogVerbose(@"Address to Geocode Mapping is Completed: %@", locatinParser.addressToGeocodeMappingDictionary);
             
             [fileManager saveAddressToGeocodeMappingDictionaryToFile:locatinParser.addressToGeocodeMappingDictionary];
             
              PSDataImporter *dataImporter = [[PSDataImporter alloc] init];
              [[dataImporter importPropertyData:properties withAddressLookData:locatinParser.addressToGeocodeMappingDictionary]
               subscribeError:^(NSError *error) {
                  LogError(@"Error While execution: %@", error);
              } completed:^{
                  LogInfo(@"Remote Data Import is Completed!!!");
                  [self logExecutionTime:startTime];
                  [self loadPropertiesFromCoreData];
                  
//                  [[self loadPropertiesFromCoreDataSignal]
//                   subscribeCompleted:^{
//                       LogError(@"Data is Refreshed: isMainThread: %@. First Property: %@", [NSThread isMainThread] ? @"YES" : @"NO", self.properties[0]);
//                   }];
//                  
//                  
              }];
         }];
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
            
            RACSignal *saleDataFetchSignal = [[self fetchPropertySaleDataWithPostParams:[postParams copy]]
                                              subscribeOn:[RACScheduler scheduler]];
            
            [saleDateSignals addObject:saleDataFetchSignal];
        }
        
        return [RACSignal merge:saleDateSignals];
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

#pragma mark - Data
- (NSArray *)properiesForSale
{
    ENTRY_LOG;
    
//    [self clearTheExistingDataInContext:[NSManagedObjectContext MR_defaultContext]];
    [self loadPropertiesFromCoreData];
    
    if([self.properties count] <= 0) {
        LogInfo(@"No existing properties at CoreData, hence importing from local cache");
        [self dataImport];
    }
    
//    self.properties = [[properties copy] subarrayWithRange:NSMakeRange(0, 10)];
    
    EXIT_LOG;
    
    return self.properties;
//    return [self.properties subarrayWithRange:NSMakeRange(0, 10)];
}

- (void)dataImport
{
    PSDataImporter *dataImporter = [[PSDataImporter alloc] init];
    [[dataImporter setupData]
     subscribeError:^(NSError *error) {
         LogError(@"Error while importing the data: %@",error);
     } completed:^{
         [self loadPropertiesFromCoreData];
         LogDebug(@"Local Cache is successfull imported into Core Data. Number of Properties: %lu", [self.properties count]);
     }];
}

- (void)loadPropertiesFromCoreData
{
    ENTRY_LOG;
    //Always Load the data using Main Thread Context
    NSArray *props = [Property MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    self.properties = [props copy];
    
//    if([props count] > 0) {
//        self.properties = props;
//    } else {
//        self.properties = nil;
//    }
    
    EXIT_LOG;
}

- (RACSignal *)loadPropertiesFromCoreDataSignal
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogError(@"Data is being Refreshed: isMainThread: %@. First Property: %@", [NSThread isMainThread] ? @"YES" : @"NO", self.properties[0]);

        //Always Load the data using Main Thread Context
        NSArray *props = [Property MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
        self.properties = [props copy];
        
        
        [subscriber sendCompleted];
        
        return nil;
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (void)reload
{
    double delayInSeconds = 4.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        LogError(@"Data reload: isMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
        
//        self.properties = nil;

        
        [self clearTheExistingDataInContext:[NSManagedObjectContext MR_defaultContext]];
        
        [self dataImport];
//        [self properiesForSale];
        
    });

}


- (void)clearTheExistingDataInContext:(NSManagedObjectContext *)localContext
{
    [Property MR_truncateAllInContext:localContext];
    [AddressLookup MR_truncateAllInContext:localContext];
    
    [localContext MR_saveToPersistentStoreAndWait];
}

- (NSArray *)getSaleDates
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];

    NSFetchedResultsController *fc = [Property MR_fetchAllGroupedBy:@"saleData" withPredicate:nil sortedBy:@"saleData" ascending:YES];
    [fc.fetchRequest setPropertiesToFetch:@[@"saleData"]];
    fc.fetchRequest.returnsDistinctResults = YES;
    [fc.fetchRequest setResultType:NSDictionaryResultType];
    
    NSArray *results = [Property MR_executeFetchRequest:fc.fetchRequest inContext:localContext];
    
    NSMutableArray *saleDates = [NSMutableArray arrayWithCapacity:[results count]];
    
    for(NSDictionary *data in results) {
        [saleDates addObject:[data objectForKey:@"saleData"]];
    }
    
    LogDebug(@"SaleDates: %@", saleDates);
    
    return [saleDates copy];
}

- (NSArray *)getSaleDatesStrings
{
    NSArray *saleDates = [self getSaleDates];
    NSMutableArray *saleDateStrings = [NSMutableArray arrayWithCapacity:[saleDates count]];
    
    for(NSDate *saleDate in saleDates) {
        [saleDateStrings addObject:[self.dateFormatter stringFromDate:saleDate]];
    }
    
    LogDebug(@"SaleDates: %@", saleDateStrings);
    
    return saleDateStrings;
}


@end
