//
//  PSLocationParser.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/15/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSLocationParser : NSObject

@property (strong, nonatomic) NSMutableArray *addresses;
@property (strong, nonatomic) NSArray *properties;
@property (strong, nonatomic) NSMutableDictionary *addressToGeocodeMappingDictionary;

- (RACSignal *)parseAddressesToCoordinates;
- (void)getCoordinates;

@end
