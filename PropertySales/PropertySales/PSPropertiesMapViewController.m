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
#import "PSGoogleMapsManager.h"
#import "PSAppleMapsManager.h"
#import "PSCoreLocationManager.h"
#import "UIColor+Theme.h"


typedef NS_ENUM(NSUInteger, MapDirectionsDestinationType) {
    MapDirectionsDestinationTypeInBuilt = 0,
    MapDirectionsDestinationTypeInGoogle = 1,
    MapDirectionsDestinationTypeInApple = 2
};


static float const kMetersPerMile = 1609.344;

@interface PSPropertiesMapViewController ()

@property (weak, nonatomic) Property *selectedProperty;
@property (strong, nonatomic) PSGoogleMapsManager *googleMapsManager;
@property (strong, nonatomic) PSAppleMapsManager *appleMapsManager;

@property (strong, nonatomic) PSCoreLocationManager *locationManager;

@end

@implementation PSPropertiesMapViewController

- (void)viewDidLoad
{
    ENTRY_LOG;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.googleMapsManager = [[PSGoogleMapsManager alloc] init];
    self.appleMapsManager = [[PSAppleMapsManager alloc] init];
    
    self.locationManager = [[PSCoreLocationManager alloc] init];
    self.locationManager.mapController = self;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    [self addCurrentLocationButton];
    [self navigateToCurrentLocation];
    
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

- (void)addCurrentLocationButton
{
    UIImageView *currentLocationImageView = [self imageViewWithImageNamed:@"CurrentLocation" tapGesture:@selector(navigateToCurrentLocation)];
    currentLocationImageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    currentLocationImageView.layer.cornerRadius = 5.0f;
    
    currentLocationImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mapView addSubview:currentLocationImageView];
    
    [self constrainCurrentLocationButton:currentLocationImageView];
}

- (void)constrainCurrentLocationButton:(UIView *)button
{
    [self.mapView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(40)]-(10)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"button":button}]];
    
    [self.mapView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[button(40)]-(10)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"button": button}]];
}

#pragma mark - CoreLocation
- (void)navigateToCurrentLocation
{
    ENTRY_LOG;

    [self.locationManager startUpdatingCurrentLocation];
    
    EXIT_LOG;
}

- (void)setupMap
{
    ENTRY_LOG;
    
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
    CLLocationCoordinate2D currentLocation;
    
    if(location.latitude != 0 && location.longitude != 0) {
        currentLocation.latitude = location.latitude;
        currentLocation.longitude= location.longitude;
    } else {
        LogError(@"Couldn't obtain the curent Location");

        currentLocation.latitude = 39.2438;
        currentLocation.longitude= -84.3853;
    }
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation, 7.5*kMetersPerMile, 7.5*kMetersPerMile);
    
    [self.mapView setRegion:viewRegion animated:NO];
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
            
            //Left Accessory
            UIImageView *leftAccessoryView = [self imageViewWithImageNamed:@"MapDirectionsArrow" tapGesture:@selector(leftCalloutAccessoryViewTapped)];
            annotationView.leftCalloutAccessoryView = leftAccessoryView;
            
            //Right Accessory
            UIButton *rightAccessory = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = rightAccessory;
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
    if([view isKindOfClass:[MKPinAnnotationView class]]) {
        self.selectedProperty = ((PSPropertyAnnotation *) view.annotation).property;
        LogDebug(@"Annotation is selected: %@", view);
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
{
    ENTRY_LOG;
    
    self.selectedProperty = ((PSPropertyAnnotation *) view.annotation).property;
    [self performSegueWithIdentifier:@"PropertyDetailsFromMapSegue" sender:self];
    
    EXIT_LOG;
}

- (void)leftCalloutAccessoryViewTapped
{
    ENTRY_LOG;
    
    UIActionSheet *directionOptions = [[UIActionSheet alloc] initWithTitle:@"Choose the type"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"In Built", @"Google Maps", @"Apple Maps", nil];
    
    [directionOptions showInView:self.view];

    EXIT_LOG;
}

#pragma mark - Directions
- (void)showDirectionsFromCurrentLocation
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
            LogError(@"Error is %@",error);
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
    renderer.strokeColor = [UIColor blueTintColor];
    renderer.lineWidth = 4.0;
    return renderer;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PropertyDetailsFromMapSegue"]) {
        PSPropertyDetailsViewController *controller = segue.destinationViewController;
        controller.selectedProperty = self.selectedProperty;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case MapDirectionsDestinationTypeInBuilt:
            LogInfo(@"InBuilt Directions Type is selected");
            [self showDirectionsFromCurrentLocation];
            break;
        case MapDirectionsDestinationTypeInGoogle:
            LogInfo(@"Google Map Directions Type is selected");
            
            [self.googleMapsManager openGoogleMapsWithDestinationAddress:self.selectedProperty.lookupAddress];
            break;
        case MapDirectionsDestinationTypeInApple:
            LogInfo(@"Apple App Directions Type is selected");
            
            [self.selectedProperty.mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:
                                                                             MKLaunchOptionsDirectionsModeDriving}];
            
            break;
        default:
            // Do Nothing.........
            break;
    }
}

#pragma mark - Utility Methods
- (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (UIImageView *)imageViewWithImageNamed:(NSString *)name tapGesture:(SEL)action
{
    UIImage *image = [UIImage imageNamed:name];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    iv.contentMode = UIViewContentModeCenter;
    iv.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [iv addGestureRecognizer:tap];
    
    return iv;
}

- (void)dealloc
{
    self.mapView.delegate = nil;
}

@end