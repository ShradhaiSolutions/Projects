//
//  NSArray+StringDescription.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 3/23/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "NSArray+StringDescription.h"

@implementation NSArray (StringDescription)

- (NSString *)stringDescription;
{
    NSMutableString *string = [[NSMutableString alloc] init];

    if([self count] > 0) {
        for(id obj in self) {
            if([obj isKindOfClass:[NSString class]]) {
                [string appendString:obj];
                [string appendString:@" "];
            }
        }
    }
    
    return string;
}

@end
