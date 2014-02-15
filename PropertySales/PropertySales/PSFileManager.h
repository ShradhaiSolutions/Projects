//
//  PSFileManager.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kPropertyMetaDataResponseFileName = @"PropertyMetaData.html";
static NSString * const kPropertySaleDataResponseFileName = @"PropertySaleData";

@interface PSFileManager : NSObject

- (RACSignal *)saveResponseHTML:(NSData *)responseData toFile:(NSString *)fileName;

@end
