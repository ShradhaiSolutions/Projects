//
//  PSPropertyAnnotation.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/18/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyAnnotation.h"
#import "AddressLookup.h"

@implementation PSPropertyAnnotation

- (void)setPropertyDetails:(Property *)property
{
    self.property = property;
    self.title = property.attyName;
    self.subtitle = [NSString stringWithFormat:@"Appraisal: %@, MinBid: %@", property.appraisal, property.minBid];;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [property.addressLookup.latitude doubleValue];
    coordinate.longitude = [property.addressLookup.longitude doubleValue];
    
    self.coordinate = coordinate;
}

@end
