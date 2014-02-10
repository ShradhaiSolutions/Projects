//
//  PSPropertyDetailsDataSource.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/10/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Property+Methods.h"

@interface PSPropertyDetailsTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) Property *selectedProperty;

@end
