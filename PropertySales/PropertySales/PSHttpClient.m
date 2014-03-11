//
//  PSHttpClient.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSHttpClient.h"

@implementation PSHttpClient

+ (AFHTTPSessionManager *)httpClient
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:kRequestURL forHTTPHeaderField:@"Referer"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];

    return manager;
}

@end
