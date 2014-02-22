//
//  PSCoreLocationManager.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/22/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PSCoreLocationManager : NSObject <CLLocationManagerDelegate>

+ (BOOL)locationServicesAuthorized;

- (void)startUpdatingCurrentLocation;
- (void)stopUpdatingCurrentLocation;

@end
