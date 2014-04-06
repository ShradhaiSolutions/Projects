//
//  SAEventDetailsDataSource.h
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 2/12/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAEvent.h"

@interface SAEventDetailsDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) SAEvent *event;

@end
