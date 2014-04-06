//
//  SAEventsDataRequest.m
//  SocialAds
//
//  Created by DHANA PRAKASH MUDDINETI on 3/3/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SAEventsDataRequest.h"

#import <AFNetworking/AFNetworking.h>
#import "SAHttpClient.h"

static NSString * const kRequestURL = @"https://d3p7lte81hpd5a.cloudfront.net/sampledata/SampleResponse";

@implementation SAEventsDataRequest
    
- (RACSignal *)invokeRequest1
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    RACScheduler *scheduler = [RACScheduler scheduler];
    
    return [[RACSignal startLazilyWithScheduler:scheduler
                                          block:^(id<RACSubscriber> subscriber) {
                                              LogDebug(@"Sending HTTP Request for Events Data");
                                              
                                              AFHTTPSessionManager *manager = [SAHttpClient httpClient];
                                              
                                              [manager GET:kRequestURL
                                                parameters:nil
                                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                                       LogDebug(@"Http response is received for Events Data");
                                                       LogVerbose(@"ResponseObject: %@", responseObject);
                                                       
                                                       [subscriber sendNext:responseObject];
                                                       
                                                       [subscriber sendCompleted];
                                                       
                                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                       LogError(@"Error: %@", error);
                                                       [subscriber sendError:error];
                                                   }];
                                              
                                          }] deliverOn:scheduler];
    
}

- (RACSignal *)invokeRequest2
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    RACScheduler *scheduler = [RACScheduler scheduler];
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogDebug(@"Sending HTTP Request for Events Data");
        
        AFHTTPSessionManager *manager = [SAHttpClient httpClient];
        
        NSURLSessionDataTask *task = [manager GET:kRequestURL
          parameters:nil
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 LogDebug(@"Http response is received for Events Data");
                 LogVerbose(@"ResponseObject: %@", responseObject);
                 
                 [subscriber sendNext:responseObject];
                 
                 [subscriber sendCompleted];
                 
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 LogError(@"Error: %@", error);
                 [subscriber sendError:error];
             }];
        
            return [RACDisposable disposableWithBlock:^{
                if(task.state != NSURLSessionTaskStateCompleted) {
                    LogError(@"Cancelling the task");
                    [task cancel];
                }
            }];
    }] deliverOn:scheduler];
}

- (RACSignal *)invokeRequest
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[RACSignal startLazilyWithScheduler:[RACScheduler scheduler]
                                          block:^(id<RACSubscriber> subscriber) {
                                              LogDebug(@"Dummy Signal");
                                              [subscriber sendNext:nil];
                                              [subscriber sendCompleted];
                                          }] flattenMap:^RACStream *(id value) {
                                              return [self invokeRequest2];
                                          }];
}

@end
