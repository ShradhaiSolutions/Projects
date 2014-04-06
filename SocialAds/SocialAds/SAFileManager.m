//
//  PSFileManager.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SAFileManager.h"

@implementation SAFileManager


- (RACSignal *)saveResponseHTML:(NSData *)responseData toFile:(NSString *)fileName
{
    ENTRY_LOG;
    
    EXIT_LOG;

    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogDebug(@"Saving html response to disk");
        NSString *responseDataString  = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        LogVerbose(@"ResponseData: %@", responseDataString);
        
        NSString *path = [self filePathFor:fileName];
        NSError *error;
        BOOL succeed = [responseDataString writeToFile:path
                                            atomically:YES
                                              encoding:NSUTF8StringEncoding error:&error];
        responseDataString = nil;
        
        if (succeed){
            // Handle error here
            LogInfo(@"Successfully saved to %@", path);
        } else {
            LogError(@"Failed to Save to %@", path);
        }
        
        [subscriber sendCompleted];
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

- (NSString *)filePathFor:(NSString *)fileName
{
    ENTRY_LOG;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    EXIT_LOG;
    
    return path;
}

@end
