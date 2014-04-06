//
//  SAEventsListDataSource.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 1/5/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SAEventsListDataSource.h"

@implementation SAEventsListDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.eventsData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SAEventsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.eventsData[0] objectForKey:@"name"];
    cell.detailTextLabel.text = [self.eventsData[0] objectForKey:@"start_time"];
    
    return cell;
}

@end
