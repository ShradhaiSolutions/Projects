//
//  PSPropertySaleDataRequest.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/14/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSPropertySaleDataRequest : NSObject

- (RACSignal *)invokeRequestWithPostParams:(NSDictionary *)postParams;

@end
