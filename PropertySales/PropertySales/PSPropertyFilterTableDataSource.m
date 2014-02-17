//
//  PSPropertyFilterTableDataSource.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/17/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyFilterTableDataSource.h"
#import "PSDataManager.h"

@interface PSPropertyFilterTableDataSource ()

@property (copy, nonatomic) NSArray *saleDates;

@end

@implementation PSPropertyFilterTableDataSource

- (id)init
{
    self = [super init];
    if (self) {
        PSDataManager *dataManager = [[PSDataManager alloc] init];
        _saleDates = [dataManager getSaleDates];
    }
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
    
    NSDate *saleDate = self.saleDates[indexPath.row];
    cell.textLabel.text = [saleDate description];
        
    return cell;
}

@end
