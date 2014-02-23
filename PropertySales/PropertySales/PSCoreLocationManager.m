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
    ENTRY_LOG;
    EXIT_LOG;
    
    return ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted);
}

- (void)configureLocationManager
{
    ENTRY_LOG;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    EXIT_LOG;
}

- (void)startUpdatingCurrentLocation
{
    ENTRY_LOG;
    
    if ([PSCoreLocationManager locationServicesAuthorized]) {
        [self configureLocationManager];
        [self.locationManager startMonitoringSignificantLocationChanges];
    } else {
        [self showSimpleAlertWithTitle:@"Enable Location Service"
                               message:@"Turn On Location Services to Allow the app to Determine Your Location"];
    }
    
    EXIT_LOG;
}

- (void)stopUpdatingCurrentLocation
{
    ENTRY_LOG;
    
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    EXIT_LOG;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    ENTRY_LOG;
    
    LogDebug(@"didUpdateToLocation: %@", locations[0]);
    CLLocation *newLocation = locations[0];
    
    [self stopUpdatingCurrentLocation];
    
    if (newLocation != nil
        && newLocation.coordinate.latitude != 0.0
        && newLocation.coordinate.longitude != 0.0) {
        LogInfo(@"Latitude: %f, Longitude: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        
        [self.mapController updateTheMapRegion:newLocation.coordinate];
    } else {
        LogError(@"Error While fetching the current Location");
        
        [self showSimpleAlertWithTitle:@"Location Error"
                               message:@"Couldn't fetch the current Location"];
    }
    
    EXIT_LOG;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    ENTRY_LOG;
    
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
    
    EXIT_LOG;
}

- (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
