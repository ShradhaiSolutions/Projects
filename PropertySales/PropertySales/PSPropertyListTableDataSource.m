//
//  PSPropertyListTableDataSource.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyListTableDataSource.h"
#import "Property+Methods.h"

@implementation PSPropertyListTableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.properties count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"PropertyListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Property *p = self.properties[indexPath.row];
    
    cell.textLabel.text = p.title;
    cell.detailTextLabel.text = p.subtitle;
    
    return cell;
}

@end
