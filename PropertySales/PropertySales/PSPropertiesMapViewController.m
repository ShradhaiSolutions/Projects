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

static float const kMetersPerMile = 1609.344;

@interface PSPropertiesMapViewController ()

@property (weak, nonatomic) Property *selectedStore;

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

    LogDebug(@"Total number of displayed annotations: %lu", [self.mapView.annotations count]);
}

- (void)setupMap
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 39.2438;
    zoomLocation.longitude= -84.3853;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 15*kMetersPerMile, 15*kMetersPerMile);
    
    [self.mapView setRegion:viewRegion animated:YES];
    self.mapView.delegate = self;
    
//    self.mapView.showsUserLocation = YES;
//    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];

    @weakify(self);
    [RACObserve(self, properties)
     subscribeNext:^(id x) {
        @strongify(self);
        LogDebug(@"Adding Annotations count: %lu", [x count]);
         
         PSDataManager *dataManager = [[PSDataManager alloc] init];
         self.saleDates = [dataManager getSaleDates];
        [self removeAllAnnotations];
        [self addAnnotations];
    } error:^(NSError *error) {
        LogError(@"Error While adding Annotations: %@", error);
    }];
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
- (void)addAnnotation:(Property *)annotation
{
    [self.mapView addAnnotation:annotation];
}

- (void)addAnnotations:(NSArray *)annotations
{
    LogInfo(@"Annotations: %lu", [annotations count]);
    LogInfo(@"Map %@", self.mapView);
    
    if(annotations) {
        [self.mapView addAnnotations:annotations];
    }
}

- (void)addAnnotations
{
    LogInfo(@"Annotations: %lu", [self.properties count]);
    LogInfo(@"Map %@", self.mapView);
    
    [self.mapView addAnnotations:self.properties];
}


- (void)removeAllAnnotations
{
    NSMutableArray * annotationsToRemove = [self.mapView.annotations mutableCopy ] ;
    [annotationsToRemove removeObject:self.mapView.userLocation ] ;
    [self.mapView removeAnnotations:annotationsToRemove ] ;
//    [self.mapView removeAnnotations:self.mapView.annotations ];
}


#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"PropertyAnnotation";
    if ([annotation isKindOfClass:[Property class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
//            annotationView.image = [UIImage imageNamed:@"ic-mappin-red-JI"];//here we use a nice image instead of the default pins
            
            NSUInteger index = [self.saleDates indexOfObject:((Property *) annotation).saleData];
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
        } else {
            annotationView.annotation = annotation;
        }
        
        //Left Accessory
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    LogDebug(@"Annotation is selected: %@", [view.annotation title]);
//    [self performSegueWithIdentifier:@"PropertyDetailsFromMapSegue" sender:self];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
{
    LogDebug(@"Annotation is selected: %@", [view.annotation title]);
    self.selectedStore = view.annotation;
    [self performSegueWithIdentifier:@"PropertyDetailsFromMapSegue" sender:self];
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PropertyDetailsFromMapSegue"]) {
        PSPropertyDetailsViewController *controller = segue.destinationViewController;
        controller.selectedProperty = self.selectedStore;
    }
}


@end