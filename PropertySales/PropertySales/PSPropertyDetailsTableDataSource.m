//
//  PSPropertyDetailsDataSource.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/10/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyDetailsTableDataSource.h"

@interface PSPropertyDetailsTableDataSource ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation PSPropertyDetailsTableDataSource

- (id)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
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
        case 3:
            cell.textLabel.text = @"CaseNo";
            cell.detailTextLabel.text = self.selectedProperty.caseNo;
            
            break;
        case 4:
            cell.textLabel.text = @"Address";
            cell.detailTextLabel.text = self.selectedProperty.address;
            
            break;
        case 5:
            cell.textLabel.text = @"Township";
            cell.detailTextLabel.text = self.selectedProperty.township;
            
            break;
        case 6:
            cell.textLabel.text = @"AttyPhone";
            cell.detailTextLabel.text = self.selectedProperty.attyPhone;
            
            break;
        case 7:
            cell.textLabel.text = @"Sale Data";
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.selectedProperty.saleData];
            
            break;
            
        default:
            break;
    }

    
    
    return cell;
}

@end
