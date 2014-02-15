//
//  PSDataCommunicator.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSDataCommunicator.h"
#import "PSPropertyMetaDataRequest.h"
#import "PSFileManager.h"

@interface PSDataCommunicator ()

@property (strong, nonatomic) PSFileManager *fileManager;

@end

@implementation PSDataCommunicator

- (id)init
{
    self = [super init];
    if (self) {
        _fileManager = [[PSFileManager alloc] init];
    }
    return self;
}

- (RACSignal *)fetchPropertyMetaData
{
    ENTRY_LOG;
    
    PSPropertyMetaDataRequest *request = [[PSPropertyMetaDataRequest alloc] init];
    
    EXIT_LOG;
    
//    return [[[request invokeRequest]
//             deliverOn:[RACScheduler scheduler] ]
//            doNext:^(id responseHtml) {
//                //Saving the data to Disk independently
//                [[self.fileManager saveResponseHTML:responseHtml toFile:kPropertyMetaDataResponseFileName]
//                 subscribeError:^(NSError *error) {
//                     LogError(@"Error While Saving the data %@", error);
//                 } completed:^{
//                     LogInfo(@"Data is successfully saved");
//                 }];
//                return;
//            }];
    
    //TODO: research to find a away for executing file manager asynchronoulsy
    return [[request invokeRequest]
            map:^id(id responseHtml) {
                //Saving the data to Disk
                [[self.fileManager saveResponseHTML:responseHtml toFile:kPropertyMetaDataResponseFileName] subscribeError:^(NSError *error) {
                    LogError(@"Error While Saving the data %@", error);
                } completed:^{
                    LogInfo(@"Data is successfully saved");
                }];
                
                return responseHtml;
            }];
}


@end
