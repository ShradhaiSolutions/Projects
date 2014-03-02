//
//  PSAboutRefreshPolicyCell.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 3/1/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSAboutRefreshPolicyCell.h"

@interface PSAboutRefreshPolicyCell ()

@property (weak, nonatomic) IBOutlet UILabel *stepperValueLabel;

- (IBAction)stepperValueChanged:(UIStepper *)sender;

@end

@implementation PSAboutRefreshPolicyCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)stepperValueChanged:(UIStepper *)sender {
    [self displayRefreshPolicyValue];
}

- (void)displayRefreshPolicyValue
{
    if(self.stepper.value == 1) {
        self.stepperValueLabel.text = [NSString stringWithFormat:@"1 hour"];
    } else {
        self.stepperValueLabel.text = [NSString stringWithFormat:@"%d hours", (int) self.stepper.value];
    }
}

@end
