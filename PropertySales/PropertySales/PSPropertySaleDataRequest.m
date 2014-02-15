//
//  PSPropertySaleDataRequest.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/14/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertySaleDataRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "PSHttpClient.h"

static NSString * const kRequestURL = @"http://apps.hcso.org/PropertySale.aspx";

@implementation PSPropertySaleDataRequest

/**
 *	Fetch the Property Sales data for a given sale date
 *
 */

- (RACSignal *)invokeRequestWithPostParams:(NSDictionary *)postParams
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        AFHTTPSessionManager *manager = [PSHttpClient httpClient];
        
        [manager POST:kRequestURL
           parameters:postParams
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  LogVerbose(@"ResponseObject: %@", responseObject);
                  
                  [subscriber sendNext:responseObject];
                  
                  [subscriber sendCompleted];
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  LogError(@"Error: %@", error);
                  [subscriber sendError:error];
              }];

        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

@end
