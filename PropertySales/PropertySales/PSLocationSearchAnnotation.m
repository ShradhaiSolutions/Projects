//
//  PSLocationSearchAnnotation.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 3/20/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSLocationSearchAnnotation.h"

@implementation PSLocationSearchAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinate title:(NSString *)title
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
    }
    return self;
}
@end
