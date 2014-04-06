//
//  SAEventDetailsViewController.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 2/12/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SAEventDetailsViewController.h"
#import "SAEventDetailsDataSource.h"

@interface SAEventDetailsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) SAEventDetailsDataSource *dataSource;

@end

@implementation SAEventDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.dataSource = [[SAEventDetailsDataSource alloc] init];
    self.dataSource.event = self.event;
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
