//
//  SAEvent.h
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 2/12/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAEvent : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *eventSource;

+ (SAEvent *) initWithTitle:(NSString *)title location:(NSString *)location date:(NSDate *)date eventSource:(NSString *)eventSource;

@end
