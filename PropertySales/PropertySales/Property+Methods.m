//
//  Property+Methods.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "Property+Methods.h"

@implementation Property (Methods)

+ (NSString *)lookupAddressWithAdress:(NSDictionary *)propertyData
{
    NSString *addr = propertyData[@"Address"];
    NSString *township = propertyData[@"Township"];
    
    return [Property lookupAddressWithAdress:addr township:township];
}


+ (NSString *)lookupAddressWithAdress:(NSString *)address township:(NSString *)township
{
    static dispatch_once_t once;
    static NSDictionary *townshipExpansion;
    dispatch_once(&once, ^ {
        townshipExpansion = @{@"CINTI":@"Cincinnati"};
    });
    
    township = [townshipExpansion objectForKey:[township uppercaseString]] ? : township;
    NSString *lookupAddress = [NSString stringWithFormat:@"%@ %@ OH USA", address, township];
    
    return lookupAddress;
    
}

- (NSString *)getAddress
{
    return [Property lookupAddressWithAdress:self.address township:self.township];
}

- (void)mapData:(NSDictionary *)propertyDictionary
{
    static dispatch_once_t once;
    static NSDateFormatter *formatter;
    dispatch_once(&once, ^ {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
    });

    self.address = propertyDictionary[@"Address"];
    self.appraisal = propertyDictionary[@"Appraisal"];
    self.attyName = propertyDictionary[@"AttyName"];
    self.attyPhone = propertyDictionary[@"AttyPhone"];
    self.caseNo = propertyDictionary[@"CaseNO"];
    self.minBid = propertyDictionary[@"MinBid"];
    self.name = propertyDictionary[@"Name"];
    self.plaintiff = propertyDictionary[@"Plaintiff"];
    self.saleData = [formatter dateFromString:propertyDictionary[@"SaleDate"]];
    self.township = propertyDictionary[@"Township"];
    self.wd = propertyDictionary[@"WD"];
    self.lookupAddress = [self getAddress];
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
