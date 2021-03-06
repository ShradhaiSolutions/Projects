//
//  PSDataImporter.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSDataImporter.h"
#import "Property+Methods.h"
#import "AddressLookup+Methods.h"
#import "PSFileManager.h"

@implementation PSDataImporter

- (RACSignal *)setupData
{
    ENTRY_LOG;

    PSFileManager *fileManager = [[PSFileManager alloc] init];
    
    NSArray *propertyData = [fileManager getPropertiesFromAppBundle];
    NSDictionary *addressLookupData = [fileManager getAddressToGeocodeMappingCacheFromAppBundle];
    
    EXIT_LOG;

    return [self importPropertyData:propertyData withAddressLookData:addressLookupData];
}

- (void)clearTheExistingDataInContext:(NSManagedObjectContext *)localContext
{
    [Property MR_truncateAllInContext:localContext];
    [AddressLookup MR_truncateAllInContext:localContext];
}

- (RACSignal *)importPropertyData:(NSArray *)propertyData withAddressLookData:(NSDictionary *)addressLookupData
{
    ENTRY_LOG;
    
    EXIT_LOG;

    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //Clear the existing data
        [self importPropertyData:propertyData addressLookData:addressLookupData];
        
        [subscriber sendCompleted];
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

- (void)importPropertyData:(NSArray *)propertyData addressLookData:(NSDictionary *)addressLookupData
{
    ENTRY_LOG;
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    [self clearTheExistingDataInContext:localContext];
    
    LogInfo(@"Importing data into CoreData. Number of Properties %lu, Number of AddressGeoCodes: %lu", [propertyData count], [addressLookupData count]);

    for (NSDictionary *propertyDictionary in propertyData) {
        
        Property *property = [Property MR_createInContext:localContext];
        [property mapData:propertyDictionary];
        
        //Relationship
        AddressLookup *addressLookup = [AddressLookup MR_findFirstByAttribute:@"lookupAddress"
                                                                    withValue:property.lookupAddress
                                                                    inContext:localContext];
        
        if(addressLookup == nil) {
            NSDictionary *coordinateDictionary = [addressLookupData objectForKey:property.lookupAddress];
            
            if(coordinateDictionary != nil &&
               coordinateDictionary[@"error"] == nil) {
                addressLookup = [AddressLookup MR_createInContext:localContext];
                addressLookup.lookupAddress = property.lookupAddress;
                addressLookup.latitude = coordinateDictionary[@"latitude"];
                addressLookup.longitude = coordinateDictionary[@"longitude"];
            }
        }
        
        property.addressLookup = addressLookup;
    }
    
    [localContext MR_saveToPersistentStoreAndWait];
    
    EXIT_LOG;
}

- (NSPredicate *)buildPredicateForProperty:(NSDictionary *)property
{
    return [NSPredicate predicateWithFormat:@"caseNo == %@, attyName == %@",
            property[@"CaseNO"], property[@"AttyName"]];

}

@end
