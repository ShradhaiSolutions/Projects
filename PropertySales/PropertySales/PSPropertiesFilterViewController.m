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
- (IBAction)dismiss:(id)sender;

@property (strong, nonatomic) PSPropertyFilterTableDataSource *dataSource;

@end

@implementation PSPropertiesFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.dataSource = [[PSPropertyFilterTableDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
