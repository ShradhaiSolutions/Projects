//
//  SAEventDetailsDataSource.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 2/12/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SAEventDetailsDataSource.h"

@implementation SAEventDetailsDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"EventDetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Title";
            cell.detailTextLabel.text = self.event.title;
            
            break;
        case 1:
            cell.textLabel.text = @"Location";
            cell.detailTextLabel.text = self.event.location;
            
            break;
        case 2:
            cell.textLabel.text = @"Data";
            cell.detailTextLabel.text = @"12-Feb-2014";
            
            break;
        case 3:
            cell.textLabel.text = @"Source";
            cell.detailTextLabel.text = self.event.eventSource;
            
            break;
            
        default:
            break;
    }
    
    return cell;
}
@end
