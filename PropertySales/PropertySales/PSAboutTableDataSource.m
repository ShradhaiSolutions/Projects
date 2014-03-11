//
//  PSAboutTableDataSource.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/27/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSAboutTableDataSource.h"
#import "PSApplicationContext.h"
#import "PSDataManager.h"
#import "NSDate+Utilities.h"
#import "UIColor+Theme.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "PSAboutRefreshPolicyCell.h"

@interface PSAboutTableDataSource ()

@end

@implementation PSAboutTableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 2) {
        return 40.0;
    } else {
        return 30.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        
        UILabel *headerText = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 160, 20)];
        headerText.backgroundColor = [UIColor clearColor];
        headerText.font = [UIFont systemFontOfSize:15];
        [headerText setText:@"Current Refresh Status"];

        [view addSubview:headerText];

        UIImage *image = [UIImage imageNamed:@"RefreshIcon"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        UIButton *refresh = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [refresh setBackgroundImage:image forState:UIControlStateNormal];

        refresh.frame = CGRectMake(180, -2, 35, 35);
        refresh.tintColor = [UIColor blueTintColor];
        
        [refresh addTarget:self action:@selector(forceDataFetch) forControlEvents:UIControlEventTouchUpInside];
        
        self.refreshButton = refresh;
        
        [view addSubview:refresh];
        return view;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    if(section == 2) {
        numberOfRows = 1;
    } else {
        numberOfRows = 2;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const infoCellIdentifier = @"AboutInfoCellIdentifier";
    static NSString * const progressCellIdentifier = @"AboutProgressCellIdentifier";
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"App Version";
                cell.detailTextLabel.text = [PSApplicationContext sharedInstance].appVersionNumber;
                
                break;
            case 1:
                cell.textLabel.text = @"Build Number";
                cell.detailTextLabel.text = [PSApplicationContext sharedInstance].buildNumber;
                
                break;
            default:
                break;
        }
    } else if(indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier forIndexPath:indexPath];

                cell.textLabel.text = @"Last Successful Refresh";
                self.lastSuccessfulDataSyncLabel = cell.detailTextLabel;
                [self displayLastSuccessfulDataSyncTimestamp];
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"AboutRefreshPolicyCellIdentifier" forIndexPath:indexPath];
                
                self.stepper = ((PSAboutRefreshPolicyCell *) cell).stepper;
                self.stepper.value = ([[PSApplicationContext sharedInstance] refreshIntervalInSeconds])/(1 * 60 *60);
                [((PSAboutRefreshPolicyCell *) cell) displayRefreshPolicyValue];
                
                break;
            default:
                break;
                
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:progressCellIdentifier forIndexPath:indexPath];
        self.progressView = (UIProgressView *) [tableView viewWithTag:10];
    }
    
    return cell;
}

- (void)displayLastSuccessfulDataSyncTimestamp
{
    static NSDateFormatter *dateFormatter;
    static NSDateFormatter *timeFormatter;
    
    if(dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd hh:mm a"];
    }

    if(timeFormatter == nil) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"hh:mm a"];
    }

    NSDate *timeStamp = [[PSApplicationContext sharedInstance] lastSuccessfulDataFetchTimestamp];
    NSString *timeStampString;
    
    if(timeStamp) {
        if([timeStamp isTodaysDate]) {
            timeStampString = [NSString stringWithFormat:@"Today %@", [timeFormatter stringFromDate:timeStamp]];
        } else {
            timeStampString = [dateFormatter stringFromDate:timeStamp];
        }
    } else {
        timeStampString = @"";
    }
    
    self.lastSuccessfulDataSyncLabel.text = timeStampString;
}

#pragma mark - Force Data Fetch
- (void)forceDataFetch
{
    RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"OK" action:^{
        [self logUserInitiatedDataFetchAnalytics];
        [[PSDataManager sharedInstance] forceDataFetch];
    }];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel" action:^{
        //Do Nothing
    }];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Data Fetch"
                                                        message:@"Do you want to force the data fetch?"
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:okItem, nil];
    [alertView show];
}

#pragma mark - Analytics
- (void)logUserInitiatedDataFetchAnalytics
{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Settings"
                                                                                        action:@"ForceDataFetch"
                                                                                         label:@"UserInitiatedDataFetch"
                                                                                         value:nil] build]];
}

@end
