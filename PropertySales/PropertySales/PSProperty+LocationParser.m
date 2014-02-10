//
//  PSProperty+LocationParser.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/6/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSProperty+LocationParser.h"
#import <MapKit/MapKit.h>

@implementation PSProperty (LocationParser)

- (RACSignal *)convertAddressToCoordinate
{
    ENTRY_LOG;
    
    NSString *address = [self getAddress];
    
    if(address == nil) {
        return [RACSignal empty];
    }
    
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        [geocoder geocodeAddressString:address
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         @strongify(self);
                         
                         if (error) {
                             LogError(@"Geocode failed with error: %@, for the address %@", error, address);
                             self.addressType = Error;
                             //TODO: find a way to handle the error with in the sequence
//                             [subscriber sendError:error];
                             [subscriber sendCompleted];
                             return;
                         }
                         
                         if(placemarks && placemarks.count > 0) {
                             if(placemarks.count > 1) {
                                 self.addressType = MultipleLocations;
                             } else {
                                 self.addressType = SingleLocation;
                             }
                             
                             CLPlacemark *placemark = placemarks[0];
                             CLLocation *location = placemark.location;
                             CLLocationCoordinate2D coords = location.coordinate;
                             
                             LogDebug(@"Latitude = %f, Longitude = %f", coords.latitude, coords.longitude);
//                             [property setObject:[NSValue valueWithMKCoordinate:coords] forKey:@"Coordinates"];
                             self.coordinates = coords;
                         } else {
                             self.AddressType = NotFound;
                             LogError(@"No coordinates are found for the address %@", address);
                         }
                         
                         [subscriber sendCompleted];
                     }
         ];
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
    
    
    EXIT_LOG;
}

@end
