//
//  SAFacebookHomeViewController.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 12/31/13.
//  Copyright (c) 2013 Social Ads. All rights reserved.
//

#import "SAFacebookHomeViewController.h"
#import "SAFacebookIntegrationHandler.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SAEventsListDataSource.h"

@interface SAFacebookHomeViewController ()

- (IBAction)signOut:(id)sender;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePicture;
@property (weak, nonatomic) IBOutlet UITableView *userEventsTableView;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (strong, nonatomic) SAEventsListDataSource *eventsDataSource;

@end

@implementation SAFacebookHomeViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [self.userInfo objectForKey:@"name"];
    self.profilePicture.profileID = [self.userInfo objectForKey:@"id"];
    
    NSArray *eventsData = [[SAFacebookIntegrationHandler sharedInstance] retrieveUserEvents];
    
    SAEventsListDataSource *eventsDataSource = [[SAEventsListDataSource alloc] init];
    eventsDataSource.eventsData = eventsData;
    
    self.eventsDataSource = eventsDataSource;
    
    self.eventsTableView.dataSource = eventsDataSource;
    self.eventsTableView.delegate = eventsDataSource;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signOut:(id)sender {
    [[SAFacebookIntegrationHandler sharedInstance] closeSessionAndClearTokenInformation];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
