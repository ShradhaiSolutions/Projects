//
//  PSPropertyFilterTableDataSource.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/17/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyFilterTableDataSource.h"
#import "PSDataManager.h"
#import "UIColor+Theme.h"

@interface PSPropertyFilterTableDataSource ()

@property (copy, nonatomic) NSArray *saleDates;
@property (copy, nonatomic) NSArray *saleDateStrings;

@end

@implementation PSPropertyFilterTableDataSource

- (id)init
{
    ENTRY_LOG;
    
    self = [super init];
    if (self) {
        PSDataManager *dataManager = [PSDataManager sharedInstance];
        _saleDates = [dataManager getSaleDates];
        _saleDateStrings = [dataManager getSaleDatesStrings];
    }
    
    EXIT_LOG;
    
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.saleDates count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"PropertyFilterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.saleDateStrings[indexPath.row];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.textColor = [UIColor redColor];
            break;
        case 1:
            cell.textLabel.textColor = [UIColor purpleColor];
            break;
            
        default:
            cell.textLabel.textColor = [UIColor greenTintColor];
            break;
    }
    
    if([self.selectedDates containsObject:self.saleDates[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
        
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogDebug(@"Selected Date: %@", self.saleDates[indexPath.row]);
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.selectedDates addObject:self.saleDates[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    [self.selectedDates removeObject:self.saleDates[indexPath.row]];
}

@end
