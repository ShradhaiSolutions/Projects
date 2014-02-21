//
//  PSPropertiesListViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertiesListViewController.h"
#import "PSPropertyListTableDataSource.h"
#import "PSPropertyDetailsViewController.h"

@interface PSPropertiesListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PSPropertyListTableDataSource *dataSource;

@end

@implementation PSPropertiesListViewController

- (void)viewDidLoad
{
    ENTRY_LOG;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    LogDebug(@"Number of Properties: %lu", [self.properties count]);
    
    self.dataSource  = [[PSPropertyListTableDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    
    @weakify(self);
    [RACObserve(self, properties)
     subscribeNext:^(id x) {
         @strongify(self);
         LogDebug(@"Number of Properties: %lu", [x count]);
         //        [self.tableView setScrollEnabled:YES];
         self.dataSource.properties = x;
         [self.tableView beginUpdates];
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
         [self.tableView endUpdates];
     }];
    
    EXIT_LOG;
}

- (void)viewWillAppear:(BOOL)animated
{
    ENTRY_LOG;
    
    [super viewWillAppear:animated];
    
    LogDebug(@"Number of Properties: %lu", [self.properties count]);

    EXIT_LOG;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Controller Containment

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (parent && self.properties)
    {
        [self.tableView reloadData];
    }
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PropertyDetailsFromListSegue"]) {
        Property *property = (Property *)[self.properties objectAtIndex:[self.tableView indexPathForSelectedRow].row];

        LogDebug(@"Selected Property: %@", property);

        PSPropertyDetailsViewController *controller = segue.destinationViewController;
        controller.selectedProperty = property;
    }
}


@end
