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
#import "PSPropertyDetailsViewController.h"
#import "PSDataManager.h"
#import "AddressLookup.h"
#import "PSPropertyAnnotation.h"

static float const kMetersPerMile = 1609.344;

@interface PSPropertiesMapViewController ()

@property (weak, nonatomic) Property *selectedProperty;

@end

@implementation PSPropertiesMapViewController

- (void)viewDidLoad
{
    ENTRY_LOG;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    EXIT_LOG;
}

- (void)viewWillAppear:(BOOL)animated
{
    ENTRY_LOG;
    
    [super viewWillAppear:animated];
    
    [self setupMap];
    LogDebug(@"Total number of displayed annotations: %lu", [self.mapView.annotations count]);
    
    EXIT_LOG;
}

- (void)setupMap
{
    ENTRY_LOG;
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 39.2438;
    zoomLocation.longitude= -84.3853;
//    zoomLocation.latitude = self.mapView.userLocation.location.coordinate.latitude;
//    zoomLocation.longitude = self.mapView.userLocation.location.coordinate.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 7.5*kMetersPerMile, 7.5*kMetersPerMile);
    
    [self.mapView setRegion:viewRegion animated:YES];
    self.mapView.delegate = self;
    
    self.mapView.showsUserLocation = YES;
//    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    
    RACSignal *willDisappear = [self rac_signalForSelector:@selector(viewWillDisappear:)];
    
    @weakify(self);
    [[RACObserve(self, properties)
      takeUntil:willDisappear]
     subscribeNext:^(id x) {
         @strongify(self);
         LogDebug(@"Adding Annotations count: %lu", [x count]);
         
         PSDataManager *dataManager = [[PSDataManager alloc] init];
         self.saleDates = [dataManager getSaleDates];
         [self addAnnotations];
     } error:^(NSError *error) {
         LogError(@"Error While adding Annotations: %@", error);
     }];
    
    EXIT_LOG;
}

- (void)updateTheMapRegion:(CLLocationCoordinate2D)location
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 39.2472;
    zoomLocation.longitude= -84.3761;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10*kMetersPerMile, 10*kMetersPerMile);
    
    // 3
    [self.mapView setRegion:viewRegion animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Annotations
- (void)addAnnotations
{
    [self removeExistingAnnotations];
    
    @autoreleasepool {
        for (Property *property in self.properties) {
            PSPropertyAnnotation *annotation = [[PSPropertyAnnotation alloc] init];
            [annotation setPropertyDetails:property];
            
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (void)removeExistingAnnotations
{
    NSMutableArray *annotations = [NSMutableArray array];
    [self.mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PSPropertyAnnotation class]]) {
            [annotations addObject:obj];
        }
    }];
    
    [self.mapView removeAnnotations:annotations];
}


#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"PropertyAnnotation";
    if ([annotation isKindOfClass:[PSPropertyAnnotation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            //            annotationView.image = [UIImage imageNamed:@"ic-mappin-red-JI"];//here we use a nice image instead of the default pins
            
            //Left Accessory
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            annotationView.annotation = annotation;
        }
        
        NSUInteger index = [self.saleDates indexOfObject:((PSPropertyAnnotation *) annotation).property.saleData];
        switch (index) {
            case 0:
                annotationView.pinColor = MKPinAnnotationColorRed;
                break;
                
            case 1:
                annotationView.pinColor = MKPinAnnotationColorPurple;
                break;
                
            default:
                annotationView.pinColor = MKPinAnnotationColorGreen;
                break;
        }
        
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.selectedProperty = ((PSPropertyAnnotation *) view.annotation).property;
    LogDebug(@"Annotation is selected: %@", [view.annotation title]);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
{
    LogDebug(@"Annotation is selected: %@", [view.annotation title]);
    self.selectedProperty = ((PSPropertyAnnotation *) view.annotation).property;
    [self performSegueWithIdentifier:@"PropertyDetailsFromMapSegue" sender:self];
}

#pragma mark - Directions
- (void)addDirectionsFromCurrentLocation
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    LogInfo(@"MapItem: %@", self.selectedProperty.mapItem);
    request.destination = self.selectedProperty.mapItem;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse *response, NSError *error) {
        LogInfo(@"MKDirectionsResponse: %@", response);
        if (error) {
            NSLog(@"Error is %@",error);
        } else {
            [self showDirections:response]; 
        } 
    }];
}

- (void)showDirections:(MKDirectionsResponse *)response
{
    ENTRY_LOG;
    for (MKRoute *route in response.routes) {
        LogDebug(@"Route: %@", route);
        [self.mapView addOverlay:route.polyline];
    }
    EXIT_LOG;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    return  renderer;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PropertyDetailsFromMapSegue"]) {
        PSPropertyDetailsViewController *controller = segue.destinationViewController;
        controller.selectedProperty = self.selectedProperty;
    }
}

- (void)dealloc
{
    self.mapView.delegate = nil;
}

@end