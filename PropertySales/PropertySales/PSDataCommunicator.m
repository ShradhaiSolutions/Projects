//
//  PSDataCommunicator.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSDataCommunicator.h"
#import "PSPropertyMetaDataRequest.h"
#import "PSPropertySaleDataRequest.h"
#import "PSFileManager.h"

@interface PSDataCommunicator ()

@property (strong, nonatomic) PSFileManager *fileManager;

@property (strong, nonatomic) NSDateFormatter *inputFormatter;
@property (strong, nonatomic) NSDateFormatter *outputFormatter;

@end

@implementation PSDataCommunicator

- (id)init
{
    self = [super init];
    if (self) {
        _fileManager = [[PSFileManager alloc] init];
        
        _inputFormatter = [[NSDateFormatter alloc] init];
        [_inputFormatter setDateFormat:@"MM/dd/yyyy"];
        
        _outputFormatter = [[NSDateFormatter alloc] init];
        [_outputFormatter setDateFormat:@"ddMMMyyyy"];

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
                [[self.fileManager saveResponseHTML:responseHtml toFile:kPropertyMetaDataResponseFileName]
                 subscribeError:^(NSError *error) {
                     LogError(@"Error While Saving the data %@", error);
                 } completed:^{
                     LogInfo(@"Data is successfully saved");
                 }];
                
                return responseHtml;
            }];
}

- (RACSignal *)fetchPropertySaleDataWithPostParams:(NSDictionary *)postParams
{
    ENTRY_LOG;
    
    PSPropertySaleDataRequest *request = [[PSPropertySaleDataRequest alloc] init];
    
    EXIT_LOG;
    
    //TODO: research to find a away for executing file manager asynchronoulsy
    return [[request invokeRequestWithPostParams:postParams]
            map:^id(id responseHtml) {
                //Saving the data to Disk
                NSString *saleDate = [postParams objectForKey:@"ddlDate"];
                NSString *fileNameSuffix = [self.outputFormatter stringFromDate:[self.inputFormatter dateFromString:saleDate]];
                NSString *fileName = [NSString stringWithFormat:@"%@_%@.html",kPropertySaleDataResponseFileName, fileNameSuffix];
                [[self.fileManager saveResponseHTML:responseHtml toFile:fileName]
                 subscribeError:^(NSError *error) {
                     LogError(@"Error While Saving the data %@", error);
                 } completed:^{
                     LogInfo(@"Data is successfully saved");
                 }];
                
                return responseHtml;
            }];
}


@end
