//
//  PSPropertySaleDatesRequest.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 3/11/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSPropertySaleDatesRequest : NSObject

- (RACSignal *)invokeRequestWithPostParams:(NSDictionary *)postParams;

@end
