//
//  PSLocationSearchResultsTableDataSource.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 3/23/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSLocationSearchResultsTableDataSource.h"
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "NSArray+StringDescription.h"

@implementation PSLocationSearchResultsTableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"LocationSearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell withData:self.searchResults[indexPath.row]];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withData:(CLPlacemark *)placemark
{
    cell.textLabel.text = [[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] stringDescription];
    LogDebug(@"Placemark Address Dictionary: %@", placemark.addressDictionary);
//    cell.textLabel.text = [NSString stringWithFormat:@"%@", ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES)];
}

@end
