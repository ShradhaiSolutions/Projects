//
//  PSPropertiesMapViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertiesMapViewController.h"
#import <MapKit/MapKit.h>
#import "Property+MKAnnotations.h"

#define METERS_PER_MILE 1609.344

@interface PSPropertiesMapViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation PSPropertiesMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupMap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    LogDebug(@"Total number of displayed annotations: %d", [self.mapView.annotations count]);
}

- (void)setupMap
{
    // 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 39.2472;
    zoomLocation.longitude= -84.3761;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 20*METERS_PER_MILE, 20*METERS_PER_MILE);
    
    // 3
    [self.mapView setRegion:viewRegion animated:YES];
    
    @weakify(self);
    [RACObserve(self, properties) subscribeNext:^(id x) {
        @strongify(self);
        LogDebug(@"Adding Annotations count: %d", [x count]);
        [self addAnnotations:x];
    } error:^(NSError *error) {
        LogError(@"Error While adding Annotations: %@", error);
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Annotations
- (void)addAnnotation:(Property *)annotation
{
    [self.mapView addAnnotation:annotation];
}

- (void)addAnnotations:(NSArray *)annotations
{
    [self.mapView addAnnotations:annotations];
}


#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"PSPropertyLocation";
    if ([annotation isKindOfClass:[Property class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"ic-mappin-red-JI"];//here we use a nice image instead of the default pins
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

@end
