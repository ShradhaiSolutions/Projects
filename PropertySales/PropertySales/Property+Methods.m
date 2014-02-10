//
//  Property+Methods.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "Property+Methods.h"

@implementation Property (Methods)

- (NSString *)getAddress
{
    NSString *address = nil;
    
    if(self.address && self.township) {
        address = [NSString stringWithFormat:@"%@ %@ OH", self.address, self.township];
    }
    
    return address;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CaseNo:%@, Plaintiff: %@, Name: %@, Address: %@,"
                             "AttyName: %@, AttyPhone: %@, Appraisal: %@, MinBid:%@,"
                             "Township:%@, WD:%@, SaleData: %@, LookupAddress: %@, LookupFromCoreData: %@",
            self.caseNo, self.plaintiff, self.name, self.address, self.attyName, self.attyPhone, self.appraisal,
            self.minBid, self.township, self.wd, self.saleData, self.lookupAddress, self.addressLookup];
}

#pragma mark - Covers Map Annotations and List Views
- (NSString *)title {
    return self.attyName;
}

- (NSString *)subtitle {
    
    return [NSString stringWithFormat:@"Appraisal: %@, MinBid: %@", self.appraisal, self.minBid];
}


@end
