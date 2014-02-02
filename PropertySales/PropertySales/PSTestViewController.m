//
//  PSTestViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/1/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSTestViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface PSTestViewController ()

@end

@implementation PSTestViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)crashMe:(id)sender {
    //    [[Crashlytics sharedInstance] crash];
    
    NSLog(@"%s Verbose ", __PRETTY_FUNCTION__);
    
    DDLogVerbose(@"%s Verbose ", __PRETTY_FUNCTION__);
    DDLogDebug(@"%s Debug ", __PRETTY_FUNCTION__);
    DDLogInfo(@"%s Info ", __PRETTY_FUNCTION__);
    DDLogWarn(@"%s Warn ", __PRETTY_FUNCTION__);
    DDLogError(@"%s Error ", __PRETTY_FUNCTION__);
    
    NSString *string = nil;
    
    NSDictionary *diction = @{@"key":@"value",
                              @"key1":string};
    
    NSLog(@"DICTIONARY: %@", diction);
    
    //    int *x = NULL; *x = 42;
}

@end
