//
//  PSPropertiesFilterViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertiesFilterViewController.h"
#import "PSPropertyFilterTableDataSource.h"

@interface PSPropertiesFilterViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PSPropertyFilterTableDataSource *dataSource;

- (IBAction)clearSelectedDates:(id)sender;
- (IBAction)applyFilter:(id)sender;

@end

@implementation PSPropertiesFilterViewController

- (void)viewDidLoad
{
    ENTRY_LOG;
    
    [super viewDidLoad];
	
    self.dataSource = [[PSPropertyFilterTableDataSource alloc] init];
    self.dataSource.selectedDates = [self.searchResultsViewModel.selectedSaleDatesForFiltering mutableCopy]; 
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    
    [[[GAI sharedInstance] defaultTracker] send:[[[GAIDictionaryBuilder createAppView] set:@"Properties Filter" forKey:kGAIScreenName] build]];

    
    EXIT_LOG;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clearSelectedDates:(id)sender
{
    ENTRY_LOG;
    
    self.dataSource.selectedDates = [NSMutableSet set];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    EXIT_LOG;
}

- (IBAction)applyFilter:(id)sender
{
    ENTRY_LOG;
    
    LogInfo(@"Selected Dates: %@", self.dataSource.selectedDates);
    
    [self logDataFilterAnalytics];
    self.searchResultsViewModel.selectedSaleDatesForFiltering = self.dataSource.selectedDates;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    EXIT_LOG;
}

#pragma mark - Analytics
- (void)logDataFilterAnalytics
{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"PropertyDataFilter"
                                                                                        action:@"FilterBySaleDate"
                                                                                         label:@"NumberOfSelectedSaleDates"
                                                                                         value:@([self.dataSource.selectedDates count])] build]];
}

@end
