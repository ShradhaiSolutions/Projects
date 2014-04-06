//
//  PSHttpClient.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface SAHttpClient : NSObject

+ (AFHTTPSessionManager *)httpClient;

@end
