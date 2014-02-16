//
//  PSDataControllerTest.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSDataImporter.h"
#import "Property+Methods.h"
#import "AddressLookup+Methods.h"

@interface PSDataImporter ()

@property (strong, nonatomic) NSDateFormatter *formatter;

@end


@implementation PSDataImporter

- (id)init
{
    self = [super init];
    if (self) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"MM/dd/yyyy"];
    }
    return self;
}

- (RACSignal *)setupData
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //Clear the existing data
//        [self clearTheExistingData];
        
        NSArray *propertyData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]
                                                                  pathForResource:@"PropertiesArray"
                                                                  ofType:@"plist"]];
        NSDictionary *addressLookupData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                                                      pathForResource:@"AddressToGeocodeMapping"
                                                                                      ofType:@"plist"]];
        
        [self importPropertyData:propertyData withAddressLookData:addressLookupData];

        [subscriber sendCompleted];

        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

- (void)clearTheExistingDataInContext:(NSManagedObjectContext *)localContext
{
    [Property MR_truncateAllInContext:localContext];
    [AddressLookup MR_truncateAllInContext:localContext];
}

- (RACSignal *)importPropertyData:(NSArray *)propertyData withAddressLookData:(NSDictionary *)addressLookupData
{
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
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    [self clearTheExistingDataInContext:localContext];

    for (NSDictionary *propertyDictionary in propertyData) {
        
        Property *property = [Property MR_createInContext:localContext];
        [self mapData:propertyDictionary toProperty:property];
        
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
}

- (NSPredicate *)buildPredicateForProperty:(NSDictionary *)property
{
    return [NSPredicate predicateWithFormat:@"caseNo == %@, attyName == %@",
            property[@"CaseNO"], property[@"AttyName"]];

}

- (void)mapData:(NSDictionary *)propertyDictionary toProperty:(Property *)property
{
    property.address = propertyDictionary[@"Address"];
    property.appraisal = propertyDictionary[@"Appraisal"];
    property.attyName = propertyDictionary[@"AttyName"];
    property.attyPhone = propertyDictionary[@"AttyPhone"];
    property.caseNo = propertyDictionary[@"CaseNO"];
    property.minBid = propertyDictionary[@"MinBid"];
    property.name = propertyDictionary[@"Name"];
    property.plaintiff = propertyDictionary[@"Plaintiff"];
    property.saleData = [self.formatter dateFromString:propertyDictionary[@"SaleDate"]];
    property.township = propertyDictionary[@"Township"];
    property.wd = propertyDictionary[@"WD"];
    property.lookupAddress = [property getAddress];
}

@end
