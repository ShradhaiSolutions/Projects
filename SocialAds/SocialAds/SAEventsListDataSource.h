//
//  SAEventsListDataSource.h
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 1/5/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAEventsListDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *eventsData;

@end
