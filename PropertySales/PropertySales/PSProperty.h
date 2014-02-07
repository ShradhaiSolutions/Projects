//
//  PSProperty.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/6/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    MultipleLocations,
    SingleLocation,
    NotFound,
    Error
} AddressType;

@interface PSProperty : NSObject

@property (strong, nonatomic) NSString *caseNo;
@property (strong, nonatomic) NSString *plaintiff;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *attyName;
@property (strong, nonatomic) NSString *attyPhone;
@property (strong, nonatomic) NSString *appraisal;
@property (strong, nonatomic) NSString *minBid;
@property (strong, nonatomic) NSString *township;
@property (strong, nonatomic) NSString *wd;
@property (strong, nonatomic) NSString *saleData;

@property (assign, nonatomic) CLLocationCoordinate2D coordinates;

@property (assign, nonatomic) AddressType addressType;

- (NSString *)getAddress;

@end
