//
//  PSLocationManager.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/4/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSLocationManager.h"
#import <AddressBook/AddressBook.h>
#import "PSProperty.h"

@implementation PSLocationManager

-(NSArray *)createPropertiesModel
{
    NSMutableArray *properties = [NSMutableArray array];
    for (NSDictionary *property in self.propertiesArray) {
        [properties addObject:[self mapToPropertyModel:property]];
    }
    return properties;
}

- (PSProperty *)mapToPropertyModel:(NSDictionary *)propertyDictionary
{
    PSProperty *property = [[PSProperty alloc] init];
    property.address = propertyDictionary[@"Address"];
    property.township = propertyDictionary[@"Township"];
    
    return property;
}

- (void)convertAddressToCoordinate:(NSString *)address withCompletion:(PSLocationSearchCompletionBlock)completion;
{
    ENTRY_LOG;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     [SVProgressHUD dismiss];
                     
                     if (error) {
                         LogError(@"Geocode failed with error: %@, for the address %@", error, address);
                         return;
                     }
                     
                     if(placemarks && placemarks.count > 0) {
                         if(completion) {
                             completion(placemarks);
                         }
                     } else {
                         LogError(@"No coordinates are found for the address %@", address);
                     }
                 }
     ];
    
    EXIT_LOG;
}

- (NSString *)getAddress:(NSMutableDictionary *)property
{
    ENTRY_LOG;
    
    NSString *addr = property[@"Address"];
    NSString *township = property[@"Township"];
    NSString *address = [NSString stringWithFormat:@"%@ %@ OH", addr, township];
    
    EXIT_LOG;
    
    return address;
}


@end
