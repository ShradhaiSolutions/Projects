//
//  PSHttpClient.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

static NSString * const kRequestURL = @"http://apps.hcso.org/PropertySale.aspx";

@interface PSHttpClient : NSObject

+ (AFHTTPSessionManager *)httpClient;

@end
