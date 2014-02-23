//
//  PSCoreLocationManager.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/22/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PSPropertiesMapViewController.h"

@interface PSCoreLocationManager : NSObject <CLLocationManagerDelegate>

@property (weak, nonatomic) PSPropertiesMapViewController *mapController;

+ (BOOL)locationServicesAuthorized;

- (void)startUpdatingCurrentLocation;
- (void)stopUpdatingCurrentLocation;

@end
