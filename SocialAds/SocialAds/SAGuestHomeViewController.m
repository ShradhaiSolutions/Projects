//
//  SAGuestHomeViewController.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 2/12/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SAGuestHomeViewController.h"
#import "SAEventListDataSource.h"
#import "SAEvent.h"
#import "SAEventDetailsViewController.h"
#import "SADataManager.h"

@interface SAGuestHomeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) SAEventListDataSource *dataSource;

@end

@implementation SAGuestHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.dataSource = [[SAEventListDataSource alloc] init];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    
    [self downloadEventsData];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EventDetailsSegue"]) {
        SAEvent *event = (SAEvent *)[self.dataSource.events objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        NSLog(@"Selected Event: %@", event);
        
        SAEventDetailsViewController *controller = segue.destinationViewController;
        controller.event = event;
    }
}

- (void)downloadEventsData
{
    [[SADataManager sharedInstance] fetchData];
    
    [SVProgressHUD showWithStatus:@"Fetching Events" maskType:SVProgressHUDMaskTypeGradient];
    
    [[RACObserve([SADataManager sharedInstance], events)
     deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        if(x != nil && [x count] > 0) {
            [SVProgressHUD dismiss];
        }
        
        LogDebug(@"Parsed Data is received");
        
        self.dataSource.events = x;
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        LogDebug(@"Table Refresh is completed");
    } error:^(NSError *error) {
        [SVProgressHUD dismiss];
        LogError(@"Error: %@", error);
    } completed:^{
        [SVProgressHUD dismiss];
        LogDebug(@"Remote Data is displayed");
    }];
}


@end
