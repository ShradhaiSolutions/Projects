//
//  PSAboutTableDataSource.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/27/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSAboutTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UIProgressView *progressView;
@property (weak, nonatomic) UILabel *lastSuccessfulDataSyncLabel;
@property (weak, nonatomic) UIButton *refreshButton;
@property (weak, nonatomic) UIStepper *stepper;

- (void)displayLastSuccessfulDataSyncTimestamp;

@end
