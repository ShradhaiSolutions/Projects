//
//  PSLocationManager.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/4/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSLocationManager.h"
#import <MapKit/MapKit.h>
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

- (void)getCoordinates
{
    ENTRY_LOG;
    
    for (NSMutableDictionary *property in self.propertiesArray) {
        [self convertAddressToCoordinate:property];
    }
    
    EXIT_LOG;
}

- (void)convertAddressToCoordinate:(NSMutableDictionary *)property
{
    ENTRY_LOG;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    NSString *address = [self getAddress:property];
    [geocoder geocodeAddressString:[self getAddress:property]
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     
                     if (error) {
                         LogError(@"Geocode failed with error: %@, for the address %@", error, address);
                         return;
                     }
                     
                     if(placemarks && placemarks.count > 0)
                     {
                         CLPlacemark *placemark = placemarks[0];
                         CLLocation *location = placemark.location;
                         CLLocationCoordinate2D coords = location.coordinate;
                         
                         LogDebug(@"Latitude = %f, Longitude = %f", coords.latitude, coords.longitude);
                         [property setObject:[NSValue valueWithMKCoordinate:coords] forKey:@"Coordinates"];
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
