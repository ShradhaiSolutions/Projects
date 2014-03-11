//
//  PSDataCommunicator.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSDataCommunicator : NSObject

- (RACSignal *)fetchPropertyMetaData;
- (RACSignal *)fetchPropertySaleDatesWithPostParams:(NSDictionary *)postParams;
- (RACSignal *)fetchPropertySaleDataWithPostParams:(NSDictionary *)postParams;

@end
