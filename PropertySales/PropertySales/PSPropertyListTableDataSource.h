//
//  PSPropertyListTableDataSource.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSPropertyListTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property(copy, nonatomic) NSArray *properties;

@end
