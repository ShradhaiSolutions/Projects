//
//  PSPropertiesMapViewController.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseViewController.h"
#import <MapKit/MapKit.h>

@interface PSPropertiesMapViewController : PSBaseViewController <MKMapViewDelegate, UIActionSheetDelegate>

@property (copy, nonatomic) NSArray *properties;
@property (copy, nonatomic) NSArray *saleDates;
@property (copy, nonatomic) CLPlacemark *locationSearchPlacemark;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (void)updateTheMapRegion:(CLLocationCoordinate2D)location;
- (void)showLocationSearchAnnotation;
- (void)removeExistingLocationSearchAnnotations;
- (void)showDirectionsFromCurrentLocation;

@end
