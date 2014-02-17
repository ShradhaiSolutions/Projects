//
//  PSPropertyDetailsTableViewCell.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/17/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyListTableViewCell.h"
#import "Property.h"

@interface PSPropertyListTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *attorneyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *apprisalValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *minBidValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *caseNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *saleDateLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation PSPropertyListTableViewCell

//This method is invocated if the cell is configured in storyboard
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    //TODO: Should be improved
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
}

- (void)configureCell:(Property *)property
{
    self.attorneyNameLabel.text = property.attyName;
    self.apprisalValueLabel.text = property.appraisal;
    self.minBidValueLabel.text = property.minBid;
    self.caseNoLabel.text = property.caseNo;
    self.saleDateLabel.text =  [self.dateFormatter stringFromDate:property.saleData];
}

@end
