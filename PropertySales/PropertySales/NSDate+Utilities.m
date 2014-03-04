//
//  NSDate+Utilities.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/28/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

- (BOOL)isTodaysDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* givenDateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];
    NSDate* givenDateWithoutTime = [calendar dateFromComponents:givenDateComponents];
    
    NSDateComponents* todayComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    NSDate* todayWithoutTime = [calendar dateFromComponents:todayComponents];
    
    return [givenDateWithoutTime compare:todayWithoutTime] == NSOrderedSame;
}

@end
