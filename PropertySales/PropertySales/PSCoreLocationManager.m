//
//  PSCoreLocationManager.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/22/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSCoreLocationManager.h"

@interface PSCoreLocationManager ()

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) CLLocation *locationBestEffort;

@end


@implementation PSCoreLocationManager

+ (BOOL)locationServicesAuthorized
{
    return ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted);
}

- (void)configureLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
}

- (void)startUpdatingCurrentLocation
{
    if ([PSCoreLocationManager locationServicesAuthorized]) {
        [self configureLocationManager];
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    else
    {
        [self showSimpleAlertWithTitle:@"Enable Location Service"
                               message:@"Turn On Location Services to Allow the app to Determine Your Location"];
    }
}

- (void)stopUpdatingCurrentLocation
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    [self stopUpdatingCurrentLocation];
    
    if (currentLocation != nil) {
        LogInfo(@"Latitude: %f, Longitude: %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    } else {
        LogError(@"Error While fetching the current Location");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorDesc = @"";
    
    switch (error.code) {
        case kCLErrorDenied:
            errorDesc = @"Access to location services was denied";
            break;
        case kCLErrorNetwork:
            errorDesc = @"Network error encountered";
            
            break;
        default:
            errorDesc = @"Error While fetching the Location";
            break;
    }
    
    [self showSimpleAlertWithTitle:@"Location Error"
                           message:errorDesc];
}

- (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"BTN_OK", "")
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
