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

@implementation PSAboutTableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
        
        UILabel *headerText = [[UILabel alloc]initWithFrame:CGRectMake(15, 1, tableView.frame.size.width, 20)];
        headerText.backgroundColor = [UIColor clearColor];
        headerText.font = [UIFont systemFontOfSize:15];
        [headerText setText:@"Current Fetch Status"];

        [view addSubview:headerText];
        
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
        cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Last Successful Fetch";
                cell.detailTextLabel.text = @"Today 10:00AM";
                
                break;
            case 1:
                cell.textLabel.text = @"Fetch Refresh Policty";
                cell.detailTextLabel.text = @"4 hours";
                
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

@end
