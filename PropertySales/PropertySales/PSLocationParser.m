//
//  PSLocationParser.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/15/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSLocationParser.h"
#import <MapKit/MapKit.h>
#import "PSFileManager.h"

@implementation PSLocationParser

- (id)init
{
    self = [super init];
    if (self) {
        _addresses = [NSMutableArray array];
        
        PSFileManager *fileManager = [[PSFileManager alloc] init];
        _addressToGeocodeMappingDictionary = [[fileManager getAddressToGeocodeMappingFromLocalCache] mutableCopy];
        
        //If the Local cache is not present, use the app bundle cache
        if(_addressToGeocodeMappingDictionary == nil) {
            _addressToGeocodeMappingDictionary = [[fileManager getAddressToGeocodeMappingCacheFromAppBundle] mutableCopy];
            
            if(_addressToGeocodeMappingDictionary == nil) {
                _addressToGeocodeMappingDictionary = [NSMutableDictionary dictionary];
            }
        }
    }
    return self;
}

- (void)getCoordinates
{
    ENTRY_LOG;
    
    __block int i=0;
    
    NSDate *startTime = [NSDate date];
    
    [[[[[RACSignal interval:1.2f onScheduler:[RACScheduler scheduler]]
        startWith:[NSDate date]]
       takeUntilBlock:^BOOL(id date) {
//           LogDebug(@"value from takeUntilBlock: %@", date);
           LogDebug(@"i value: %d", i);
           return  (i >= [self.properties count]); //(i >= 3); //(i == [self.properties count]);
       }] flattenMap:^RACStream *(id date) {
           int j = i;
           for(NSMutableDictionary *property in
               [self.properties subarrayWithRange:NSMakeRange(j, ([self.properties count] - j))]) {
               //Increment the main index
               i++;
               
//               if(i > 3) {
//                   break;
//               }
               
               NSString *nextAddress = [self getAddress:property];
               NSDictionary *geoCodeInfo = [self.addressToGeocodeMappingDictionary objectForKey:nextAddress];
               
               if(geoCodeInfo == nil ||
                  [geoCodeInfo objectForKey:@"error"] != nil) {
                   LogInfo(@"Parsing the address: %@", nextAddress);
                   return [self convertAddressToCoordinate:nextAddress];
               } else {
                   LogVerbose(@"Retrieved the geocode from cache for the address: %@", nextAddress);
                   continue;
               }
           }
           
           return [RACSignal empty];
           
       }] subscribeNext:^(id x) {
           LogInfo(@"Next Value: %@", x);
       } error:^(NSError *error) {
           LogError(@"Error: %@", error);
       } completed:^{
           LogVerbose(@"Completed: %@", self.addressToGeocodeMappingDictionary);
           
           PSFileManager *fileManager = [[PSFileManager alloc] init];
           [fileManager saveAddressToGeocodeMappingDictionaryToFile:self.addressToGeocodeMappingDictionary];
           
           [self logExecutionTime:startTime];
       }];
    
    EXIT_LOG;
}

- (RACSignal *)parseAddressesToCoordinates
{
    //To track the index
    __block int i=0;
    
    return [[[[RACSignal interval:1.2f onScheduler:[RACScheduler scheduler]]
        startWith:[NSDate date]]
       takeUntilBlock:^BOOL(id date) {
           LogDebug(@"i value: %d", i);
           return  (i >= [self.properties count]);
       }] flattenMap:^RACStream *(id date) {
           int j = i;
           for(NSMutableDictionary *property in
               [self.properties subarrayWithRange:NSMakeRange(j, ([self.properties count] - j))]) {
              
               //Increment the main index
               i++;
               
               NSString *nextAddress = [self getAddress:property];
               NSDictionary *geoCodeInfo = [self.addressToGeocodeMappingDictionary objectForKey:nextAddress];
               
               if(geoCodeInfo == nil ||
                  [geoCodeInfo objectForKey:@"error"] != nil) {
                   LogInfo(@"Parsing the address: %@", nextAddress);
                   return [self convertAddressToCoordinate:nextAddress];
               } else {
                   LogVerbose(@"Retrieved the geocode from cache for the address: %@", nextAddress);
                   continue;
               }
           }
           
           return [RACSignal empty];
           
       }];

}

- (RACSignal *)convertAddressToCoordinate:(NSString *)address
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        [geocoder geocodeAddressString:address
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         if (error) {
                             LogError(@"Geocode failed with error: %@, for the address %@", error, address);
                             [self.addressToGeocodeMappingDictionary setObject:@{@"error":
                                                                       [NSString stringWithFormat:@"Failed with the address: %@",error]}
                                                          forKey:address];
                             [subscriber sendCompleted];
                             return;
                         }
                         
                         if(placemarks && placemarks.count > 0) {
                             //                             if(placemarks.count > 1) {
                             //                                 self.addressType = MultipleLocations;
                             //                             } else {
                             //                                 self.addressType = SingleLocation;
                             //                             }
                             
                             CLPlacemark *placemark = placemarks[0];
                             CLLocation *location = placemark.location;
                             CLLocationCoordinate2D coords = location.coordinate;
                             
                             LogDebug(@"Latitude = %f, Longitude = %f", coords.latitude, coords.longitude);
                             [self.addressToGeocodeMappingDictionary setObject:@{@"latitude":@(coords.latitude),
                                                                   @"longitude": @(coords.longitude)}
                                                          forKey:address];
                             //                             self.coordinates = coords;
                         } else {
                             [self.addressToGeocodeMappingDictionary setObject:@{@"error":@"NotFound"}
                                                          forKey:address];
                             
                             LogError(@"No coordinates are found for the address %@", address);
                         }
                         
                         [subscriber sendCompleted];
                     }
         ];
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

- (void)convertAddressToCoordinate1:(NSString *)address
{
    ENTRY_LOG;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:address
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
                         [self.addressToGeocodeMappingDictionary setObject:[NSValue valueWithMKCoordinate:coords]
                                                      forKey:address];
                     } else {
                         LogError(@"No coordinates are found for the address %@", address);
                     }
                 }
     ];
    
    EXIT_LOG;
}

- (NSString *)getAddress:(NSMutableDictionary *)property
{
//    ENTRY_LOG;
    
    NSString *addr = property[@"Address"];
    NSString *township = property[@"Township"];
    NSString *address = [NSString stringWithFormat:@"%@ %@ OH USA", addr, township];
    
//    EXIT_LOG;
    
    return address;
}

@end
