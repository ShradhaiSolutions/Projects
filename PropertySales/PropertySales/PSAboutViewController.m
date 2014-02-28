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

@interface PSAboutViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PSAboutTableDataSource *dataSource;

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
         
         [self.dataSource.progressView setProgress:[progress floatValue] animated:YES];
         
         if([progress floatValue] == 1.0) {
             [self.dataSource displayLastSuccessfulDataSyncTimestamp];
         }
         
     } error:^(NSError *error) {
         LogError(@"Error While getting fetch progress: %@", error);
         [self.dataSource.progressView setProgress:1.0 animated:YES];
     }];
    
    EXIT_LOG;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissAboutPage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
