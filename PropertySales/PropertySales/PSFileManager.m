//
//  PSFileManager.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSFileManager.h"

//NSString *PROPERTY_SALES_RESPONSE_HTML_FILE_NAME = @"responseData2.html";
//NSString *PROPERTY_SALES_DATA_ARRAY_FILE_NAME = @"PropertiesArray.plist";
//NSString *PROPERTY_SALES_DATA_DICTIONARY_FILE_NAME = @"PropertiesDictionary.plist";
//NSString *LOCATION_COORDINATES_MAP_DICTIONARY_FILE_NAME = @"LocationCoordinates.plist";


@implementation PSFileManager


- (RACSignal *)saveResponseHTML:(NSData *)responseData toFile:(NSString *)fileName
{
    ENTRY_LOG;
    
    EXIT_LOG;

    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
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
        
//        [subscriber sendNext:responseData];
        
        [subscriber sendCompleted];
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

//-(void)savePropertiesToFile:(NSArray *)propertiesArray
//{
//    ENTRY_LOG;
//    
//    NSString *path = [self filePathFor:PROPERTY_SALES_DATA_DICTIONARY_FILE_NAME];
//    
//    BOOL succeed = [propertiesArray writeToFile:path atomically:YES];
//    if (succeed){
//        // Handle error here
//        LogInfo(@"Successfully saved to %@", path);
//    } else {
//        LogError(@"Failed to Save to %@", path);
//    }
//    
//    EXIT_LOG;
//}
//
//-(void)saveLocationsMap:(NSDictionary *)locationCoordinatesMap
//{
//    ENTRY_LOG;
//    
//    NSString *path = [self filePathFor:LOCATION_COORDINATES_MAP_DICTIONARY_FILE_NAME];
//    
//    BOOL succeed = [locationCoordinatesMap writeToFile:path atomically:YES];
//    if (succeed){
//        // Handle error here
//        LogInfo(@"Successfully saved to %@", path);
//    } else {
//        LogError(@"Failed to Save to %@", path);
//    }
//    
//    EXIT_LOG;
//}

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
