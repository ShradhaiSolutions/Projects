//
//  PSPropertySaleDataParser.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/15/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSPropertySaleDataParser : NSObject

- (RACSignal *)parsePropertySalesInformation:(NSData *)responseData;

@end
