//
//  PSPropertyDetailsDataSource.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/10/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyDetailsTableDataSource.h"

@implementation PSPropertyDetailsTableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"PropertyDetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Attorney";
            cell.detailTextLabel.text = self.selectedProperty.attyName;

            break;
        case 1:
            cell.textLabel.text = @"Appraisal";
            cell.detailTextLabel.text = self.selectedProperty.appraisal;
            
            break;
        case 2:
            cell.textLabel.text = @"MinBid";
            cell.detailTextLabel.text = self.selectedProperty.minBid;
            
            break;
            
        default:
            break;
    }

    
    
    return cell;
}

@end
