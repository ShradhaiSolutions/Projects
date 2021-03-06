//
//  PSDataManager.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSDataManager.h"
#import "PSDataCommunicator.h"
#import "PSPropertyMetadataDataParser.h"
#import "PSPropertySaleDatesParser.h"
#import "PSPropertySaleDataParser.h"
#import "PSFileManager.h"
#import "PSLocationParser.h"
#import "PSDataImporter.h"

#import "Property.h"
#import "AddressLookup.h"

#import "PSApplicationContext.h"

double kDataFetchFailure = -1.0;
double kDataFetchSuccess = 1.0;

@interface PSDataManager ()

@property (strong, nonatomic) PSDataCommunicator *communicator;
@property (strong, nonatomic) PSLocationParser *locationParser;

@property (strong, nonatomic) NSDictionary *postParams;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
    
@property (strong, nonatomic) NSArray *saleDates;
@property (strong, nonatomic) NSArray *saleDateStrings;

@end

@implementation PSDataManager
    
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PSDataManager *sharedManagerInstance;
    dispatch_once(&once, ^ {
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
        _dataFetchProgress = @(kDataFetchSuccess);
    }
    return self;
}

- (void)fetchData
{
    ENTRY_LOG;
    
    if([self shouldRefreshTheData]
       && (([self.dataFetchProgress doubleValue] == kDataFetchSuccess)
           || ([self.dataFetchProgress doubleValue] == kDataFetchFailure))) {
           [self forceDataFetch];
       } else {
           LogInfo(@"Data Refresh Interval is not crossed, hence skipping");
       }
    
    EXIT_LOG;
}

- (void)forceDataFetch
{
    ENTRY_LOG;
    
    NSDate *startTime = [NSDate date];
    
    __block NSMutableArray *properties = [NSMutableArray array];
    self.communicator = [[PSDataCommunicator alloc] init];
    
    self.dataFetchProgress = @0.0;
    
    @weakify(self);
    [[[[[[[self fetchPropertyMetaData]
         flattenMap:^RACStream *(id metaDataDictionary) {
             LogDebug(@"Property Meta Data is received");
             LogVerbose(@"Parsed Metadata: %@", metaDataDictionary);
             
             self.dataFetchProgress = @0.1;
             
             return [self fetchPropertySaleDatesWithPasedMetadata:metaDataDictionary];
         }] flattenMap:^RACStream *(id metaDataDictionary) {
             LogDebug(@"Property Meta Data is received");
             LogVerbose(@"Parsed Metadata: %@", metaDataDictionary);
             
             self.dataFetchProgress = @0.2;
             
             return [self fetchPropertySalesWithPasedMetadata:metaDataDictionary];
         }] flattenMap:^RACStream *(id propertiesOfASaleDate) {
             LogDebug(@"Property Sale Data is received");
             LogVerbose(@"Parsed Metadata: %@", propertiesOfASaleDate);
             
             [properties addObjectsFromArray:propertiesOfASaleDate];
             
             self.dataFetchProgress = @([self.dataFetchProgress floatValue] + 0.1);
             
             //After receiving all the properties information send an empty signal so that the "block" will be executed
             return [RACSignal empty];
         }] then:^RACSignal *{
             @strongify(self);
             LogInfo(@"Property data is downloaded and parsed. Total Number of Properties: %lu", (unsigned long)[properties count]);
             [self logExecutionTime:startTime];
             
             self.communicator = nil;
             
             PSFileManager *fileManager = [[PSFileManager alloc] init];
             [fileManager savePropertiesToFile:properties];
             
             self.locationParser = [[PSLocationParser alloc] init];
             self.locationParser.properties = properties;
             
             return [self.locationParser parseAddressesToCoordinates];
         }] then:^RACSignal *{
             LogInfo(@"Addresses are parsed to Coordinates successfully");
             [self logExecutionTime:startTime];
             
             self.dataFetchProgress = @0.8;
             
             PSFileManager *fileManager = [[PSFileManager alloc] init];
             [fileManager saveAddressToGeocodeMappingDictionaryToFile:self.locationParser.addressToGeocodeMappingDictionary];
             
             PSDataImporter *dataImporter = [[PSDataImporter alloc] init];
             
             return [dataImporter importPropertyData:properties withAddressLookData:self.locationParser.addressToGeocodeMappingDictionary];
         }] subscribeNext:^(id x) {
             LogVerbose(@"Next Value: %@", x);
         } error:^(NSError *error) {
             LogError(@"Error While execution: %@", error);
             
             //Failure
             self.dataFetchProgress = @(kDataFetchFailure);
             
             [self logExecutionTime:startTime];
             [self logDataFetchError:error];
         } completed:^{
             properties = nil;
             self.locationParser = nil;
             
             [[PSApplicationContext sharedInstance] saveSuccessfulDataFetchTimestamp];
             
             self.dataFetchProgress = @(kDataFetchSuccess);
             
             [self logExecutionTime:startTime];
             [self loadPropertiesFromCoreDataOnMainThread];

             [self logDataFetchTime:[[NSDate date] timeIntervalSinceDate:startTime]];
             LogInfo(@"Remote Data Import is Completed!!!");
         }];
    
    EXIT_LOG;
}

#pragma mark - Fetch Property Metadata
- (RACSignal *)fetchPropertyMetaData
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[self.communicator fetchPropertyMetaData]
            flattenMap:^RACStream *(id responseData) {
                LogDebug(@"Property Metadata response is received");
                PSPropertyMetadataDataParser *parser = [[PSPropertyMetadataDataParser alloc] init];
                return [parser parsePropertySalesInitialRequest:responseData];
            }];
    
}

#pragma mark - Fetch Property Sale Dates
- (RACSignal *)fetchPropertySaleDatesWithPasedMetadata:(NSDictionary *)parsedData
{
    ENTRY_LOG;
    
    NSMutableDictionary *postParams = [parsedData mutableCopy];
    [postParams removeObjectForKey:@"SaleDatesArray"];

    LogInfo(@"Fetching the Property Sale Dates");
    [postParams setObject:@"Upcoming Foreclosures" forKey:@"btnCurrent"];

    return [self fetchPropertySaleDatesWithPostParams:[postParams copy]];
    
    EXIT_LOG;
}

- (RACSignal *)fetchPropertySaleDatesWithPostParams:(NSDictionary *)postParams
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[self.communicator fetchPropertySaleDatesWithPostParams:postParams]
            flattenMap:^RACStream *(id responseData) {
                LogDebug(@"Property Sale Dates response is received");
                PSPropertySaleDatesParser *parser = [[PSPropertySaleDatesParser alloc] init];
                return [parser parsePropertySaleDatesResponse:responseData];
            }];
    
}


#pragma mark - Fetch Property Saledata
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
            [postParams setObject:@"" forKey:@"ddlTown"];
            [postParams setObject:@"" forKey:@"txtAddress"];
            [postParams setObject:@"" forKey:@"txtAddress_TextBoxWatermarkExtender_ClientState"];
            [postParams setObject:@"GO" forKey:@"btnGo"];
            [postParams setObject:@"" forKey:@"txtCaseno"];
            
            RACSignal *saleDataFetchSignal = [self fetchPropertySaleDataWithPostParams:[postParams copy]];
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
                LogDebug(@"Property Sale Data response is received");
                PSPropertySaleDataParser *parser = [[PSPropertySaleDataParser alloc] init];
                return [parser parsePropertySalesInformation:responseData];
            }];
    
}

#pragma mark - Data
- (NSArray *)properiesForSale
{
    ENTRY_LOG;
    
    [self loadPropertiesFromCoreData];
    
    if([self.properties count] <= 0) {
        LogInfo(@"No existing properties at CoreData, hence importing from local cache");
        [self dataImport];
    }
    
    [self fetchSaleDatesFromCoreData];
    
    EXIT_LOG;
    
    return self.properties;
}

- (void)dataImport
{
    PSDataImporter *dataImporter = [[PSDataImporter alloc] init];
    [[dataImporter setupData]
     subscribeError:^(NSError *error) {
         LogError(@"Error while importing the data: %@",error);
     } completed:^{
         [self loadPropertiesFromCoreData];
         LogDebug(@"Local Cache is successfull imported into Core Data. Number of Properties: %lu", (unsigned long)[self.properties count]);
     }];
}

- (void)loadPropertiesFromCoreDataOnMainThread
{
    ENTRY_LOG;
    
    [[RACSignal startEagerlyWithScheduler:[RACScheduler mainThreadScheduler]
                                    block:^(id<RACSubscriber> subscriber) {
                                        LogDebug(@"Loading properties from Core Data on Main thread - Start");
                                        //Always Load the data using Main Thread Context
                                        NSArray *props = [Property MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
                                        self.properties = [props copy];
                                        [self fetchSaleDatesFromCoreData];
                                        LogDebug(@"Loading properties from Core Data on Main thread - End");
                                    }] subscribeOn:[RACScheduler mainThreadScheduler]];
    
    EXIT_LOG;
}

- (void)loadPropertiesFromCoreData
{
    ENTRY_LOG;

    //Always Load the data using Main Thread Context
    NSArray *props = [Property MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    self.properties = [props copy];
    
    [self fetchSaleDatesFromCoreData];
    
    EXIT_LOG;
}

- (void)clearTheExistingDataInContext:(NSManagedObjectContext *)localContext
{
    [Property MR_truncateAllInContext:localContext];
    [AddressLookup MR_truncateAllInContext:localContext];
    
    [localContext MR_saveToPersistentStoreAndWait];
}

- (NSArray *)getSaleDates
{
    ENTRY_LOG;
    
    if(self.saleDates == nil) {
        [self fetchSaleDatesFromCoreData];
    }
    
    EXIT_LOG;
    
    return self.saleDates;
}
    
- (void)fetchSaleDatesFromCoreData
{
    ENTRY_LOG;
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    
    NSFetchedResultsController *fc = [Property MR_fetchAllGroupedBy:@"saleData" withPredicate:nil sortedBy:@"saleData" ascending:YES];
    [fc.fetchRequest setPropertiesToFetch:@[@"saleData"]];
    fc.fetchRequest.returnsDistinctResults = YES;
    [fc.fetchRequest setResultType:NSDictionaryResultType];
    
    NSArray *results = [Property MR_executeFetchRequest:fc.fetchRequest inContext:localContext];
    
    NSMutableArray *saleDates = [NSMutableArray arrayWithCapacity:[results count]];
    NSMutableArray *saleDateStrings = [NSMutableArray arrayWithCapacity:[results count]];
    
    for(NSDictionary *data in results) {
        NSDate *saleDate = [data objectForKey:@"saleData"];
        [saleDates addObject:saleDate];
        [saleDateStrings addObject:[self.dateFormatter stringFromDate:saleDate]];
    }
    
    LogDebug(@"SaleDate Strings: %@", saleDateStrings);
    
    self.saleDates = [saleDates copy];
    self.saleDateStrings = [saleDateStrings copy];
    
    EXIT_LOG;
}

- (NSArray *)getSaleDatesStrings
{
    if(self.saleDateStrings == nil) {
        [self fetchSaleDatesFromCoreData];
    }

    return self.saleDateStrings;
}

#pragma mark - Should Refresh
- (BOOL)shouldRefreshTheData
{
    BOOL refreshRequired = YES;
    
    NSDate *lastSuccessfulRefreshDate = [[PSApplicationContext sharedInstance] lastSuccessfulDataFetchTimestamp];
    
    if(lastSuccessfulRefreshDate) {
        NSUInteger interval = [[PSApplicationContext sharedInstance] refreshIntervalInSeconds];

        NSTimeInterval elapstedTime = fabs([lastSuccessfulRefreshDate timeIntervalSinceNow]);
        
        LogDebug(@"{elapstedTime: %f, refreshInterval:%lu}", elapstedTime, (unsigned long)interval);
        
        if(elapstedTime > interval) {
            refreshRequired = YES;
        } else {
            refreshRequired = NO;
        }
    } else {
        LogDebug(@"Last Successful Refresh Date is not present, hence data should be fetched");
        refreshRequired = YES;
    }
    
    LogInfo(@"ShouldRefreshData: %@", refreshRequired ? @"YES" : @"NO");
    
    return refreshRequired;
}

#pragma mark - Analytics
- (void)logDataFetchTime:(NSTimeInterval)fetchTime
{
    //If we send the whole number, the value is not popping up at Analytics
    int fetchIntervalInMilliSeconds = abs(fetchTime * 1000);
    
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createTimingWithCategory:@"DataFetch"
                                                                                       interval:@(fetchIntervalInMilliSeconds)
                                                                                           name:@"TotalDataFetchTime"
                                                                                          label:@"TotalDataFetchTime"] build]];
}

- (void)logDataFetchError:(NSError *)error
{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Error"
                                                                                        action:@"DataFetchError"
                                                                                         label:[error domain]
                                                                                         value:@([error code])] build]];
    
}

@end
