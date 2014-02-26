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
@property (strong, nonatomic) PSLocationParser *locationParser;

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
        _locationParser = [[PSLocationParser alloc] init];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }
    return self;
}

- (void)fetchData
{
    ENTRY_LOG;
    
    NSDate *startTime = [NSDate date];
    
    NSMutableArray *properties = [NSMutableArray array];
    
    @weakify(self);
    [[[[[[self fetchPropertyMetaData]
      flattenMap:^RACStream *(id metaDataDictionary) {
          LogDebug(@"Property Meta Data is received");
          LogVerbose(@"Parsed Metadata: %@", metaDataDictionary);
          
          return [self fetchPropertySalesWithPasedMetadata:metaDataDictionary];
      }] flattenMap:^RACStream *(id propertiesOfASaleDate) {
          LogDebug(@"Property Sale Data is received");
          LogVerbose(@"Parsed Metadata: %@", propertiesOfASaleDate);
          
          [properties addObjectsFromArray:propertiesOfASaleDate];
          
          //After receiving all the properties information send an empty signal so that the "block" will be executed
          return [RACSignal empty];
      }] then:^RACSignal *{
          @strongify(self);
          LogInfo(@"Property data is downloaded and parsed. Total Number of Properties: %lu", [properties count]);
          [self logExecutionTime:startTime];
          
          PSFileManager *fileManager = [[PSFileManager alloc] init];
          [fileManager savePropertiesToFile:properties];
          
          self.locationParser.properties = properties;
          
          return [self.locationParser parseAddressesToCoordinates];
      }] then:^RACSignal *{
          LogInfo(@"Addresses are parsed to Coordinates successfully");
          [self logExecutionTime:startTime];
          
          PSFileManager *fileManager = [[PSFileManager alloc] init];
          [fileManager saveAddressToGeocodeMappingDictionaryToFile:self.locationParser.addressToGeocodeMappingDictionary];
          
          PSDataImporter *dataImporter = [[PSDataImporter alloc] init];
          
          return [dataImporter importPropertyData:properties withAddressLookData:self.locationParser.addressToGeocodeMappingDictionary];
      }] subscribeNext:^(id x) {
          LogDebug(@"2. Property Sale Data is received for a given sale date");
          LogVerbose(@"Next Value: %@", x);
      } error:^(NSError *error) {
          LogError(@"Error While execution: %@", error);
          [self logExecutionTime:startTime];
      } completed:^{
          [self logExecutionTime:startTime];
          [self loadPropertiesFromCoreDataOnMainThread];
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
         LogDebug(@"Local Cache is successfull imported into Core Data. Number of Properties: %lu", [self.properties count]);
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
