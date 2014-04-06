//
//  PSDataCommunicator.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SADataCommunicator.h"
#import "SAFileManager.h"
#import "SAEventsDataRequest.h"

@interface SADataCommunicator ()

@property (strong, nonatomic) SAFileManager *fileManager;

@property (strong, nonatomic) NSDateFormatter *inputFormatter;
@property (strong, nonatomic) NSDateFormatter *outputFormatter;

@end

@implementation SADataCommunicator

- (id)init
{
    self = [super init];
    if (self) {
        _fileManager = [[SAFileManager alloc] init];
        
        _inputFormatter = [[NSDateFormatter alloc] init];
        [_inputFormatter setDateFormat:@"MM/dd/yyyy"];
        
        _outputFormatter = [[NSDateFormatter alloc] init];
        [_outputFormatter setDateFormat:@"ddMMMyyyy"];

    }
    return self;
}

- (RACSignal *)fetchEventsData
{
    ENTRY_LOG;
    
    SAEventsDataRequest *request = [[SAEventsDataRequest alloc] init];
    
    EXIT_LOG;
    
    //TODO: research to find a away for executing file manager asynchronoulsy
    return [[request invokeRequest]
            map:^id(id responseData) {
                LogDebug(@"Http Response is received for Events Data");

#if TARGET_IPHONE_SIMULATOR
                //Saving the data to Disk
                [[self.fileManager saveResponseHTML:responseData toFile:kEventsResponseFileName]
                 subscribeError:^(NSError *error) {
                     LogError(@"Error While Saving the data %@", error);
                 } completed:^{
                     LogInfo(@"Html Response is successfully saved to disk");
                 }];
#endif
                LogDebug(@"Http Response map block is completed");
                
                return responseData;
            }];
}

@end
