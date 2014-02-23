//
//  PSDataImporter.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSDataImporter : NSObject

- (RACSignal *)setupData;

- (RACSignal *)importPropertyData:(NSArray *)propertyData withAddressLookData:(NSDictionary *)addressLookupData;

@end
