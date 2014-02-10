//
//  PSPropertyDetailsViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/10/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyDetailsViewController.h"
#import "PSPropertyDetailsTableDataSource.h"

@interface PSPropertyDetailsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PSPropertyDetailsTableDataSource *dataSource;

@end

@implementation PSPropertyDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.dataSource  = [[PSPropertyDetailsTableDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    
    self.dataSource.selectedProperty = self.selectedProperty;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
