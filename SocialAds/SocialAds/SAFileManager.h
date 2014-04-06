//
//  PSFileManager.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kEventsResponseFileName = @"Events.json";

@interface SAFileManager : NSObject

- (RACSignal *)saveResponseHTML:(NSData *)responseData toFile:(NSString *)fileName;

@end
