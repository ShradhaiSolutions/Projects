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
#import "PSPropertiesFilterViewController.h"
#import "PSDataController.h"
#import "PSDataManager.h"
#import "PSCoreLocationManagerDelegate.h"
#import "PSSearchResultsViewModel.h"

static NSString *const kPropertiesListStoryboardIdentifier = @"PropertiesList";
static NSString *const kPropertiesMapStoryboardIdentifier = @"PropertiesMap";


@interface PSPropertiesContainerViewController () <UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *searchToolbar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewTypeSegmentControl;

- (IBAction)viewTypeSegmentControlValueChanged:(id)sender;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PSCoreLocationManagerDelegate *locationManagerDelegate;

@property (strong, nonatomic) PSSearchResultsViewModel *searchResultsViewModel;

@property (strong, nonatomic) UIGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIGestureRecognizer *panGestureRecognizer;

@end

@implementation PSPropertiesContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Data Setup
	PSDataManager *dataManager = [[PSDataManager alloc] init];
    
    self.searchResultsViewModel = [[PSSearchResultsViewModel alloc] init];
    self.searchResultsViewModel.properties = [dataManager properiesForSale];
    
    RAC(self, searchResultsViewModel.properties) = RACObserve(dataManager, properties);

    [dataManager properiesForSale];
    [dataManager fetchData];
    [dataManager getSaleDates];
    
    LogDebug(@"Number of Properties: %lu", [self.searchResultsViewModel.propertiesFromSearchResult count]);
    
    RAC(self.searchResultsViewModel, searchString) = RACObserve(self, searchBar.text);
    [self.searchResultsViewModel setup];
    
    self.searchBar.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManagerDelegate = [[PSCoreLocationManagerDelegate alloc] init];
    self.locationManager.delegate = self.locationManagerDelegate;
    
    //Add the child view controller
    [self addMapViewController];
}

- (void)addMapViewController
{
    PSPropertiesMapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:kPropertiesMapStoryboardIdentifier];
    
    RAC(mapViewController, properties) = RACObserve(self.searchResultsViewModel, propertiesFromSearchResult);
    
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
    
    if([childViewController isKindOfClass:[PSPropertiesListViewController class]]) {
        PSPropertiesListViewController *vc = (PSPropertiesListViewController *)childViewController;
        RAC(vc, properties) = RACObserve(self.searchResultsViewModel, propertiesFromSearchResult);
    } else {
        PSPropertiesMapViewController *vc = (PSPropertiesMapViewController *)childViewController;
        RAC(vc, properties) = RACObserve(self.searchResultsViewModel, propertiesFromSearchResult);
    }
    
    childViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    LogDebug(@"Search Text: %@", self.searchBar.text);
    [self swapChildViewControllers];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    ENTRY_LOG;
    
    [self addGestureRecognizersToKeyWindow];
    
    EXIT_LOG;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    ENTRY_LOG;
    
    [self removeGestureRecognizersFromKeyWindow];
    
    EXIT_LOG;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    ENTRY_LOG;
    
    [self.searchBar resignFirstResponder];

    EXIT_LOG;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    ENTRY_LOG;
    
    self.searchResultsViewModel.searchString = searchText;
    
    EXIT_LOG;
}

#pragma mark - UIGestureRecognizer

- (void)addGestureRecognizersToKeyWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureWhileSearching:)];
    self.tapGestureRecognizer.delegate = self;
    [keyWindow addGestureRecognizer:self.tapGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureWhileSearching:)];
    self.panGestureRecognizer.delegate = self;
    [keyWindow addGestureRecognizer:self.panGestureRecognizer];
}

- (void)removeGestureRecognizersFromKeyWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow removeGestureRecognizer:self.tapGestureRecognizer];
    [keyWindow removeGestureRecognizer:self.panGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Handling Keyboard Dismissal
- (void)handleTapGestureWhileSearching:(UIGestureRecognizer *)recognizer
{
    if (recognizer == self.tapGestureRecognizer) {
        CGPoint touchPoint = [recognizer locationInView:self.view];
        CGRect barRect = [self.view convertRect:self.searchBar.frame fromView:self.searchBar.superview];
        
        if (!CGRectContainsPoint(barRect, touchPoint)) {
            [self.searchBar resignFirstResponder];
        }
    }
}

- (void)handlePanGestureWhileSearching:(UIGestureRecognizer *)recognizer
{
    if (recognizer == self.panGestureRecognizer) {
        CGPoint touchPoint = [recognizer locationInView:self.view];
        if (!CGRectContainsPoint(self.searchBar.frame, touchPoint)) {
            [self.searchBar resignFirstResponder];
        }
    }
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PropertiesFilterSegue"]) {
        PSPropertiesFilterViewController *controller = [segue.destinationViewController childViewControllers][0];
        controller.searchResultsViewModel = self.searchResultsViewModel;
    }
}

@end
