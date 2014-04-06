//
//  PSPropertySaleDatesParser.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 3/11/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSPropertySaleDatesParser : NSObject

- (RACSignal *)parsePropertySaleDatesResponse:(NSData *)responseData;

@end
