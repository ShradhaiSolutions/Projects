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

static NSString * const kRequestURL = @"http://apps.hcso.org/PropertySale.aspx";

@implementation PSPropertyMetaDataRequest

/**
 *	Fetch the initial data (meta data) from the website
 *
 */
- (RACSignal *)invokeRequest
{
    ENTRY_LOG;

    EXIT_LOG;

    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        AFHTTPSessionManager *manager = [PSHttpClient httpClient];
                
        [manager GET:kRequestURL
          parameters:nil
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 LogVerbose(@"ResponseObject: %@", responseObject);
                 
                 [subscriber sendNext:responseObject];

                 [subscriber sendCompleted];

             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 LogError(@"Error: %@", error);
                 [subscriber sendCompleted];
             }];
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

@end
