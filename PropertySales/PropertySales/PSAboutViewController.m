//
//  PSAboutViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/27/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSAboutViewController.h"
#import "PSAboutTableDataSource.h"
#import "PSDataManager.h"
#import "UIColor+Theme.h"
#import "PSApplicationContext.h"

@interface PSAboutViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PSAboutTableDataSource *dataSource;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (IBAction)dismissAboutPage:(id)sender;

@end

@implementation PSAboutViewController

- (void)viewDidLoad
{
    ENTRY_LOG;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.dataSource  = [[PSAboutTableDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    
    [[[GAI sharedInstance] defaultTracker] send:[[[GAIDictionaryBuilder createAppView] set:@"About" forKey:kGAIScreenName] build]];
    
    EXIT_LOG;
}

-  (void)viewWillAppear:(BOOL)animated
{
    ENTRY_LOG;
    
    RACSignal *willDisappear = [self rac_signalForSelector:@selector(viewWillDisappear:)];
    
    @weakify(self);
    [[[RACObserve([PSDataManager sharedInstance], dataFetchProgress)
      takeUntil:willDisappear] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSNumber *progress) {
         @strongify(self);
         LogDebug(@"Data Fetch Progress Value: %@", progress);
         
         if([progress floatValue] == kDataFetchSuccess) {
             [self.dataSource displayLastSuccessfulDataSyncTimestamp];
             [self stopActivityIndicator:YES];
         } else if([progress floatValue] == kDataFetchFailure) {
             [self stopActivityIndicator:NO];
         } else {
             [self.dataSource.progressView setProgress:[progress floatValue] animated:YES];
             [self startActivityIndicatorIfNecessary];
         }
         
     } error:^(NSError *error) {
         LogError(@"Error While getting fetch progress: %@", error);
         [self stopActivityIndicator:NO];
     }];
    
    EXIT_LOG;
}

- (void)viewWillDisappear:(BOOL)animated
{
    int numberOfHours = self.dataSource.stepper.value;
    
    [[PSApplicationContext sharedInstance] updateRefreshInterval:@(numberOfHours * 60 * 60)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissAboutPage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Activity Indicator
- (void)startActivityIndicatorIfNecessary
{
    if([self.activityIndicator isAnimating]) {
        return;
    }
    
    if(self.activityIndicator == nil) {
        UIActivityIndicatorView *activityInd = [[UIActivityIndicatorView alloc]
                                                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityInd stopAnimating];
        activityInd.color = [UIColor blueTintColor];
        
        activityInd.frame = self.dataSource.refreshButton.bounds;
        //        [activityInd setUserInteractionEnabled:NO];
        
        self.activityIndicator = activityInd;
    }
    
    [self.activityIndicator startAnimating];
    [self.dataSource.refreshButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.dataSource.refreshButton addSubview:self.activityIndicator];
    self.dataSource.progressView.progressTintColor = [UIColor blueTintColor];
}

- (void)stopActivityIndicator:(BOOL)success
{
    if(self.activityIndicator != nil) {
        UIImage *image = [UIImage imageNamed:@"RefreshIcon"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [self.activityIndicator stopAnimating];
        [self.dataSource.refreshButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    if(success) {
        self.dataSource.progressView.progressTintColor = [UIColor blueTintColor];
    } else {
        self.dataSource.progressView.progressTintColor = [UIColor redTintColor];
    }
    
    [self.dataSource.progressView setProgress:1.0 animated:YES];
}

@end
