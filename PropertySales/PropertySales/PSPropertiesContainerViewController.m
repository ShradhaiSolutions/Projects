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
#import "PSDataManager.h"
#import "PSCoreLocationManagerDelegate.h"
#import "PSSearchResultsViewModel.h"
#import "PSLocationManager.h"

static NSString *const kPropertiesListStoryboardIdentifier = @"PropertiesList";
static NSString *const kPropertiesMapStoryboardIdentifier = @"PropertiesMap";

typedef NS_ENUM(NSUInteger, SearchType) {
    SearchTypeProperty = 0,
    SearchTypeLocation = 1
};

@interface PSPropertiesContainerViewController () <UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) PSSearchResultsViewModel *searchResultsViewModel;
@property (strong, nonatomic) UIGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIGestureRecognizer *panGestureRecognizer;
@property (assign, nonatomic) SearchType searchType;

@property (weak, nonatomic) IBOutlet UIToolbar *searchToolbar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchTypeButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewTypeSegmentControl;

- (IBAction)viewTypeSegmentControlValueChanged:(id)sender;
- (IBAction)toggleSearchType:(id)sender;

@end


@implementation PSPropertiesContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Data Setup
	PSDataManager *dataManager = [PSDataManager sharedInstance];
    
    self.searchResultsViewModel = [[PSSearchResultsViewModel alloc] init];
    self.searchResultsViewModel.properties = [dataManager properiesForSale];
    
    RAC(self, searchResultsViewModel.properties) = RACObserve(dataManager, properties);

    [dataManager properiesForSale];
    [dataManager fetchData];
    [dataManager getSaleDates];
    
    LogDebug(@"Number of Properties: %lu", (unsigned long)[self.searchResultsViewModel.propertiesFromSearchResult count]);
    
    RAC(self.searchResultsViewModel, searchString) = RACObserve(self, searchBar.text);
    [self.searchResultsViewModel setup];

//    [self setupSearch];
    
    self.searchBar.delegate = self;
    
    //Setup SearchType
    self.searchType = SearchTypeProperty;
    [self.searchTypeButton setTitle:@"P"];
    
    //Add the child view controller
    [self addMapViewController];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    [self setupSearch];
//}

- (void)setupSearch
{
    ENTRY_LOG;
    
    RACSignal *willDisappear = [self rac_signalForSelector:@selector(viewWillDisappear:)];
    
    @weakify(self);
    [[RACObserve(self, searchBar.text)
      takeUntil:willDisappear]
     subscribeNext:^(NSString *searchString) {
         @strongify(self);
         NSLog(@"SearchString: %@", searchString);
         
//         if(self.searchType == SearchTypeProperty) {
//             self.searchResultsViewModel.searchString = searchString;
//         } else {
//             NSLog(@"SearchType - Location: %@", searchString);
//         }
     } error:^(NSError *error) {
         LogError(@"Error While adding Annotations: %@", error);
     }];
    
    [self.searchResultsViewModel setup];
    
    EXIT_LOG;
}

- (void)addMapViewController
{
    PSPropertiesMapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:kPropertiesMapStoryboardIdentifier];
    
    RAC(mapViewController, properties) = RACObserve(self.searchResultsViewModel, propertiesFromSearchResult);
    
    mapViewController.view.frame = self.view.bounds;
    mapViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addChildViewController:mapViewController];
    [self.view addSubview:mapViewController.view];
    
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
    
    [self.view addSubview:childViewController.view];
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

- (IBAction)toggleSearchType:(id)sender {
    if(self.searchType == SearchTypeProperty) {
        self.searchType = SearchTypeLocation;
        [self.searchTypeButton setTitle:@""];

        UIImage *image = [UIImage imageNamed:@"MapPin"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [self.searchTypeButton setImage:image];
        self.searchTypeButton.tintColor = [UIColor blueColor];
    } else {
        self.searchType = SearchTypeProperty;
        [self.searchTypeButton setImage:nil];
        [self.searchTypeButton setTitle:@"P"];
        
        UIImage *image = [UIImage imageNamed:@"PropertyIcon"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        [self.searchTypeButton setImage:image];
//        self.searchTypeButton.tintColor = [UIColor clearColor];
    }
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
    
    [self logSearchAnalytics:self.searchBar.text];
    [self.searchBar resignFirstResponder];
    
    if(self.searchType == SearchTypeLocation) {
        [SVProgressHUD showWithStatus:@"Finding Address" maskType:SVProgressHUDMaskTypeGradient];
        PSLocationManager *locationManager = [[PSLocationManager alloc] init];
        [locationManager convertAddressToCoordinate:searchBar.text withCompletion:^(CLLocationCoordinate2D coords) {
            [((PSPropertiesMapViewController *) [self.childViewControllers firstObject]) addLocationSearchAnnotation:coords];
        }];
    }

    EXIT_LOG;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    ENTRY_LOG;
    
    if(self.searchType == SearchTypeProperty) {
        self.searchResultsViewModel.searchString = searchText;
    } else {
        NSLog(@"SearchType - Address: %@", searchText);
    }
    
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
            [self logSearchAnalytics:self.searchBar.text];
            [self.searchBar resignFirstResponder];
        }
    }
}

- (void)handlePanGestureWhileSearching:(UIGestureRecognizer *)recognizer
{
    if (recognizer == self.panGestureRecognizer) {
        CGPoint touchPoint = [recognizer locationInView:self.view];
        if (!CGRectContainsPoint(self.searchBar.frame, touchPoint)) {
            [self logSearchAnalytics:self.searchBar.text];
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

#pragma mark - Analytics
- (void)logSearchAnalytics:(NSString *)searchTerm
{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"PropertyDataSearch"
                                                                                        action:@"SearchBySearchTerm"
                                                                                         label:searchTerm
                                                                                         value:@([self.searchResultsViewModel.propertiesFromSearchResult count])] build]];
}

@end
