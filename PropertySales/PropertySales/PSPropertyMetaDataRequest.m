//
//  PSPropertyMetaDataRequest.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyMetaDataRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "PSHttpClient.h"

@implementation PSPropertyMetaDataRequest

/**
 *	Fetch the initial data (meta data) from the website
 *
 */
- (RACSignal *)invokeRequest
{
    ENTRY_LOG;

    EXIT_LOG;
    
    RACScheduler *scheduler = [RACScheduler scheduler];
    
    return [[RACSignal startLazilyWithScheduler:scheduler
                                          block:^(id<RACSubscriber> subscriber) {
                                              LogDebug(@"Sending HTTP Request for Property Metadata");
                                              
                                              AFHTTPSessionManager *manager = [PSHttpClient httpClient];
                                              
                                              [manager GET:kRequestURL
                                                parameters:nil
                                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                                       LogDebug(@"Http response is received for Property Metadata");
                                                       LogVerbose(@"ResponseObject: %@", responseObject);
                                                       
                                                       [subscriber sendNext:responseObject];
                                                       
                                                       [subscriber sendCompleted];
                                                       
                                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                       LogError(@"Error: %@", error);
                                                       [subscriber sendError:error];
                                                   }];
                                              
                                          }] deliverOn:scheduler];

}

@end
