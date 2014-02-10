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

@implementation PSDataImporter

- (RACSignal *)setupData
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //Clear the existing data
        [self clearTheExistingData];
        
        NSArray *propertyData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]
                                                                  pathForResource:@"PropertiesDictionary"
                                                                  ofType:@"plist"]];
        NSDictionary *addressLookupData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                                                      pathForResource:@"LocationCoordinates"
                                                                                      ofType:@"plist"]];
        
        [self importPropertyData:propertyData addressLookData:addressLookupData];

        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [subscriber sendCompleted];
        });

        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
    

}

- (void)clearTheExistingData
{
    [Property MR_truncateAll];
    [AddressLookup MR_truncateAll];
}

- (void)importPropertyData:(NSArray *)propertyData addressLookData:(NSDictionary *)addressLookupData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    for (NSDictionary *dict in propertyData) {
        Property *property = [Property MR_createInContext:localContext];
        property.address = dict[@"Address"];
        property.appraisal = dict[@"Appraisal"];
        property.attyName = dict[@"AttyName"];
        property.attyPhone = dict[@"AttyPhone"];
        property.caseNo = dict[@"CaseNO"];
        property.minBid = dict[@"MinBid"];
        property.name = dict[@"Name"];
        property.plaintiff = dict[@"Plaintiff"];
        property.saleData = [formatter dateFromString:dict[@"SaleDate"]];
        property.township = dict[@"Township"];
        property.wd = dict[@"WD"];
        property.lookupAddress = [property getAddress];
        
        //Relationship
        AddressLookup *addressLookup = [AddressLookup MR_findFirstByAttribute:@"lookupAddress"
                                                                    withValue:[property getAddress]
                                                                    inContext:localContext];
        
        if(addressLookup == nil) {
            NSDictionary *coordinateDictionary = [addressLookupData objectForKey:property.lookupAddress];
            
            if(coordinateDictionary != nil) {
                addressLookup = [AddressLookup MR_createInContext:localContext];
                addressLookup.lookupAddress = property.lookupAddress;
                addressLookup.latitude = coordinateDictionary[@"lat"];
                addressLookup.longitude = coordinateDictionary[@"long"];
            }
        }
        
        property.addressLookup = addressLookup;
    }
    
    [localContext MR_saveToPersistentStoreAndWait];
}

@end
