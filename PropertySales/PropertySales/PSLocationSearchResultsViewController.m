//
//  PSLocationSearchResultsViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 3/23/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSLocationSearchResultsViewController.h"
#import "PSLocationSearchResultsTableDataSource.h"

@interface PSLocationSearchResultsViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PSLocationSearchResultsTableDataSource *dataSource;

- (IBAction)dismissViewController:(id)sender;
@end

@implementation PSLocationSearchResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.dataSource = [[PSLocationSearchResultsTableDataSource alloc] init];
    self.dataSource.searchResults = self.searchResults;
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogDebug(@"Selected Address: %@", self.searchResults[indexPath.row]);
    [self.delegate addLocationSearchAnnotation:self.searchResults[indexPath.row]];
    [self dismissViewController:nil];
}

@end
