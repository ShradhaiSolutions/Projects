//
//  PSAboutRefreshPolicyCell.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 3/1/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSAboutRefreshPolicyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIStepper *stepper;

- (void)displayRefreshPolicyValue;

@end
