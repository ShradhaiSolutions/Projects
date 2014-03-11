//
//  Property+Methods.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "Property.h"

@interface Property (Methods)

+ (NSString *)lookupAddressWithAdress:(NSDictionary *)propertyData;
+ (NSString *)lookupAddressWithAdress:(NSString *)address township:(NSString *)township;

- (void)mapData:(NSDictionary *)propertyDictionary;
- (NSString *)getAddress;

- (NSString *)title;
- (NSString *)subtitle;

@end
