//
//  AddressLookup+Methods.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/8/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "AddressLookup+Methods.h"

@implementation AddressLookup (Methods)

- (NSString *)description
{
    return [NSString stringWithFormat:@"LookupAddress:%@, Latitude: %@, Longitude: %@ ",
            self.lookupAddress, self.latitude, self.longitude];
}

@end
