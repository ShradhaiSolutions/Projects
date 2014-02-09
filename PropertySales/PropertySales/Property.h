//
//  Property.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/8/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AddressLookup;

@interface Property : NSManagedObject

@property (nonatomic, retain) NSString * caseNo;
@property (nonatomic, retain) NSString * plaintiff;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * attyName;
@property (nonatomic, retain) NSString * attyPhone;
@property (nonatomic, retain) NSString * appraisal;
@property (nonatomic, retain) NSString * minBid;
@property (nonatomic, retain) NSString * township;
@property (nonatomic, retain) NSString * wd;
@property (nonatomic, retain) NSDate * saleData;
@property (nonatomic, retain) NSNumber * addressType;
@property (nonatomic, retain) NSString * lookupAddress;
@property (nonatomic, retain) AddressLookup *addressLookup;

@end
