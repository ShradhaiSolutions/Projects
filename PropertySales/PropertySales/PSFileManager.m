//
//  PSFileManager.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSFileManager.h"

@implementation PSFileManager


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

- (void)savePropertiesToFile:(NSArray *)propertiesArray
{
    ENTRY_LOG;
    
    [[[self signalForSavingPropertiesToFile:propertiesArray]
      subscribeOn:[RACScheduler scheduler]]
     subscribeCompleted:^{
         LogInfo(@"Done");
     }];


    EXIT_LOG;
}

- (RACSignal *)signalForSavingPropertiesToFile:(NSArray *)propertiesArray
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSString *path = [self filePathFor:kPropertySalesArrayFileName];
        
        BOOL succeed = [propertiesArray writeToFile:path atomically:YES];

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
    
    
    EXIT_LOG;
}

- (void)saveAddressToGeocodeMappingDictionaryToFile:(NSDictionary *)addressToGeocodeMapping
{
    ENTRY_LOG;
    
    [[[self signalForSavingAddressToGeocodeMapping:addressToGeocodeMapping]
      subscribeOn:[RACScheduler scheduler]]
     subscribeCompleted:^{
         LogInfo(@"Done");
     }];
    
    
    EXIT_LOG;
}

- (RACSignal *)signalForSavingAddressToGeocodeMapping:(NSDictionary *)addressToGeocodeMapping
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSString *path = [self filePathFor:kAddressToGeocodeMappingDictionaryFileName];
        
        BOOL succeed = [addressToGeocodeMapping writeToFile:path atomically:YES];
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
    
    
    EXIT_LOG;
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

#pragma mark - Utility methods
- (NSArray *)getPropertiesFromLocalCache
{
    ENTRY_LOG;
    
    NSString *path = [self filePathFor:kPropertySalesArrayFileName];
    
    NSArray *propertiesArray = [NSArray arrayWithContentsOfFile:path];
    
    EXIT_LOG;
    
    return propertiesArray;
    
}

- (NSDictionary *)getAddressToGeocodeMappingFromLocalCache
{
    ENTRY_LOG
    
    NSString *path = [self filePathFor:kAddressToGeocodeMappingDictionaryFileName];
    
    NSDictionary *locationCoordinatesMap = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return locationCoordinatesMap;
    
    EXIT_LOG
}

- (NSArray *)getPropertiesFromAppBundle
{
    ENTRY_LOG;

    NSArray *propertiesArray = [NSArray arrayWithContentsOfFile:
                                [[NSBundle mainBundle]
                                 pathForResource:kPropertySalesAppBundleFileName
                                 ofType:@"plist"]];
    
    LogInfo(@"Number of Properties from App Bundle: %lu", [propertiesArray count]);
    
    EXIT_LOG;
    
    return propertiesArray;
    
}

- (NSDictionary *)getAddressToGeocodeMappingCacheFromAppBundle
{
    ENTRY_LOG
    
    NSDictionary *locationCoordinatesMap = [NSDictionary dictionaryWithContentsOfFile:
                                            [[NSBundle mainBundle]
                                             pathForResource:kAddressToGeocodeMappingAppBundleFileName
                                             ofType:@"plist"]];
    
    
    LogInfo(@"Number of AddressToGeocodeMapping from App Bundle: %lu", [locationCoordinatesMap count]);

    return locationCoordinatesMap;
    
    EXIT_LOG
}


@end
