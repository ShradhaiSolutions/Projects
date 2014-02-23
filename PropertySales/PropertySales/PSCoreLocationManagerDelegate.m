//
//  PSCoreLocationManagerDelegate.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/10/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSCoreLocationManagerDelegate.h"

@implementation PSCoreLocationManagerDelegate

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    LogError(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    LogDebug(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        LogInfo(@"Latitude: %f, Longitude: %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    }
}

@end
