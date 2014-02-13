//
//  PSPropertiesContainerViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertiesContainerViewController.h"
#import "PSPropertiesListViewController.h"
#import "PSPropertiesMapViewController.h"
#import "PSDataController.h"
#import "PSCoreLocationManagerDelegate.h"

typedef enum : NSUInteger
{
    viewTypeSegmentIndexMap = 0,
    viewTypeSegmentIndexList
} viewTypeSegmentIndex;

static NSString *const kMapFilterSegueIdentifier = @"MapFilterSegue";
static NSString *const kMapFilterStoryboardIdentifier = @"PropertiesFilter";
static NSString *const kPropertiesListStoryboardIdentifier = @"PropertiesList";
static NSString *const kPropertiesMapStoryboardIdentifier = @"PropertiesMap";


@interface PSPropertiesContainerViewController ()

@property (weak, nonatomic) IBOutlet UIToolbar *searchToolbar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewTypeSegmentControl;

- (IBAction)viewTypeSegmentControlValueChanged:(id)sender;
- (IBAction)navigateToCurrentLocation:(id)sender;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PSCoreLocationManagerDelegate *locationManagerDelegate;

@property(copy, nonatomic) NSArray *properties;

@end

@implementation PSPropertiesContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Data Setup
	PSDataController *dataController = [[PSDataController alloc] init];
    self.properties = [dataController properiesForSale];
    LogDebug(@"Number of Properties: %lu", [self.properties count]);
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManagerDelegate = [[PSCoreLocationManagerDelegate alloc] init];
    self.locationManager.delegate = self.locationManagerDelegate;
    
    //Add the child view controller
    [self addMapViewController];
}

- (void)addListViewController
{
    PSPropertiesListViewController *listViewController = [self.storyboard instantiateViewControllerWithIdentifier:kPropertiesListStoryboardIdentifier];

    listViewController.view.frame = self.view.bounds;
    listViewController.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self addChildViewController:listViewController];
    [self.view insertSubview:listViewController.view belowSubview:self.searchToolbar];

    [listViewController didMoveToParentViewController:self];
    
    [self constrainChildControllerView:listViewController.view];
}

- (void)addMapViewController
{
    PSPropertiesListViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:kPropertiesMapStoryboardIdentifier];
    mapViewController.properties = self.properties;
    
    mapViewController.view.frame = self.view.bounds;
    mapViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addChildViewController:mapViewController];
    [self.view insertSubview:mapViewController.view belowSubview:self.searchToolbar];
    
    [mapViewController didMoveToParentViewController:self];
    
    [self constrainChildControllerView:mapViewController.view];
}

#pragma mark - ChildViewController
- (void)swapChildViewControllers
{
    UIViewController *currentViewController = [self childViewControllers][0];
    NSString *storyboardIdentifier = [currentViewController isKindOfClass:[PSPropertiesListViewController class]] ? kPropertiesMapStoryboardIdentifier : kPropertiesListStoryboardIdentifier;
    
    UIViewController *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    
    childViewController.view.frame = currentViewController.view.frame;
    childViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [childViewController setValue:self.properties forKeyPath:@"properties"];
    
    if([childViewController isKindOfClass:[PSPropertiesListViewController class]]) {
        LogDebug(@"Setting the properties");
        ((PSPropertiesListViewController *)childViewController).properties = self.properties;
    }
    
    [self addChildViewController:childViewController];
    [currentViewController willMoveToParentViewController:nil];
    
    [self.view insertSubview:childViewController.view belowSubview:self.searchToolbar];
    [childViewController didMoveToParentViewController:self];
    [self constrainChildControllerView:childViewController.view];
    
    [currentViewController.view removeFromSuperview];
    [currentViewController removeFromParentViewController];
}

- (void)constrainChildControllerView:(UIView *)child
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[searchBar]-(0)-[childView]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"searchBar":self.searchToolbar, @"childView":child}]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[child]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"child": child}]];
}

- (IBAction)viewTypeSegmentControlValueChanged:(id)sender {
    [self swapChildViewControllers];
}

#pragma mark - CoreLocation
- (IBAction)navigateToCurrentLocation:(id)sender {
    ENTRY_LOG;
    
    [self.locationManager startUpdatingLocation];
    
    PSPropertiesMapViewController *mapViewController = (PSPropertiesMapViewController *) self.childViewControllers[0];

    CLLocation *location = (CLLocation *) mapViewController.mapView.userLocation;
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        [self showSimpleAlertWithTitle:@"Location" message:@"Location Service is disabled. Please enable it in Settings."];
    }
    else if (!location) {
        [self showSimpleAlertWithTitle:@"Location" message:@"Failed to obtain location information"];
    }
    else {
        LogInfo(@"Current Location: Latitude: %f, Longitude: %f", location.coordinate.latitude, location.coordinate.longitude);
        
        [mapViewController updateTheMapRegion:location.coordinate];

    }
    
    [self.locationManager stopUpdatingLocation];
    
    EXIT_LOG;
}

- (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"BTN_OK", "") otherButtonTitles:nil];
    [alertView show];
}


@end
