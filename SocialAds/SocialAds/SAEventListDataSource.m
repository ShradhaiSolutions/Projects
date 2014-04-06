//
//  SAEventListDataSource.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 2/12/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SAEventListDataSource.h"
#import "SAEvent.h"

@interface SAEventListDataSource ()

@end

@implementation SAEventListDataSource

- (id)init
{
    self = [super init];
    if (self) {
//        NSMutableArray *events = [NSMutableArray array];
        
//        SAEvent *event = [SAEvent initWithTitle:@"Mid-week Meeting" location:@"Anil's House" date:[NSDate date] eventSource:@"Team"];
//
//        [events addObject:event];
//        [events addObject:[SAEvent initWithTitle:@"Find a Telugu Movide" location:@"Cincinati" date:[NSDate date] eventSource:@"Dhana"]];
//        [events addObject:[SAEvent initWithTitle:@"Say Hello" location:@"Harper's Point" date:[NSDate date] eventSource:@"Facebook"]];
//        
//        self.events = [events copy];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"EventListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    SAEvent *p = self.events[indexPath.row];
    
    cell.textLabel.text = p.title;
    cell.detailTextLabel.text = p.location;
    
    return cell;
}

@end
