//
//  PSPropertySaleDatesRequest.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 3/11/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertySaleDatesRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "PSHttpClient.h"

@implementation PSPropertySaleDatesRequest

/**
 *	Fetch the initial data (meta data) from the website
 *
 */
- (RACSignal *)invokeRequestWithPostParams:(NSDictionary *)postParams
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogDebug(@"Sending HTTP Request for Property Sales Data");
        
        AFHTTPSessionManager *manager = [PSHttpClient httpClient];
        
        [manager POST:kRequestURL
           parameters:postParams
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  LogDebug(@"Http response is received for Property Sales Data");
                  LogVerbose(@"ResponseObject: %@", responseObject);
                  
                  [subscriber sendNext:responseObject];
                  
                  [subscriber sendCompleted];
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  LogError(@"Error: %@", error);
                  [subscriber sendError:error];
              }];
        
        manager = nil;
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }] deliverOn:[RACScheduler scheduler]];
}

@end
