//
//  PSPropertyDetailsTableViewCell.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/17/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Property.h"

@interface PSPropertyListTableViewCell : UITableViewCell

- (void)configureCell:(Property *)property;

@end
