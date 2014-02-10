//
//  PSPropertiesListViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertiesListViewController.h"
#import "PSPropertyListTableDataSource.h"

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
    
    LogDebug(@"Number of Properties: %d", [self.properties count]);
    
    self.dataSource  = [[PSPropertyListTableDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    
    RAC(self.dataSource, properties) = [RACObserve(self, properties) doNext:^(id x) {
        LogDebug(@"Number of Properties: %d", [x count]);
        [self.tableView setScrollEnabled:YES];
        [self.tableView reloadData];
    }];
    
    
    EXIT_LOG;
}

- (void)viewWillAppear:(BOOL)animated
{
    ENTRY_LOG;
    
    [super viewWillAppear:animated];
    
    LogDebug(@"Number of Properties: %d", [self.properties count]);

    EXIT_LOG;
}

//- (void)setProperties:(NSArray *)properties
//{
//    _properties = properties;
//    if([_properties count] > 0) {
////        [self.tableView setScrollEnabled:YES];
//        self.dataSource.properties = self.properties;
//        [self.tableView reloadData];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Controller Containment

//- (void)willMoveToParentViewController:(UIViewController *)parent
//{
//    if (parent && [parent conformsToProtocol:@protocol(KRStoreLocatorChildViewControllerDelegate)])
//    {
//        __weak KRStoresViewController *weakSelf = self;
//        [self.childDelegate setCompletionBlockWithSuccess:^(NSArray *stores, NSArray *services, CLLocation *location) {
//            weakSelf.stores = stores;
//            [weakSelf.tableView reloadData];
//        } failure:^(NSError *error) {
//            [weakSelf handleSearchError];
//        }];
//    }
//}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (parent && self.properties)
    {
        [self.tableView reloadData];
    }
}

@end
