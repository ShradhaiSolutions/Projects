//
//  PSProperty.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/6/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSProperty.h"

@implementation PSProperty

- (NSString *)getAddress
{
    ENTRY_LOG;
    
    NSString *address = nil;
    
    if(self.address && self.township) {
        address = [NSString stringWithFormat:@"%@ %@ OH", self.address, self.township];
    }

    EXIT_LOG;

    return address;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Address: %@, Township: %@, Latitude = %f, Longitude = %f AddressType: %u",
            self.address, self.township, self.coordinates.latitude, self.coordinates.longitude, self.addressType];
}

@end
