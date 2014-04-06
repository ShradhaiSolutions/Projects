//
//  SAEvent.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 2/12/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SAEvent.h"

@implementation SAEvent

+ (SAEvent *) initWithTitle:(NSString *)title location:(NSString *)location date:(NSDate *)date eventSource:(NSString *)eventSource;
{
    SAEvent *event = [[SAEvent alloc] init];
    
    if(event) {
        event.title = title;
        event.location = location;
        event.date = date;
        event.eventSource = eventSource;
    }
    
    return event;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Title: %@, Location: %@, date: %@, source: %@", self.title, self.location, self.date, self.eventSource];
}

@end
