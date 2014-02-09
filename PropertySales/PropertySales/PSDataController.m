//
//  PSDataController.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/3/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSDataController.h"
#import <AFNetworking/AFNetworking.h>
#import "TFHpple.h"

NSString *requestURL = @"http://apps.hcso.org/PropertySale.aspx";
NSString *INITIAL_REQUEST_RESPONSE_HTML_FILE_NAME = @"responseData1.html";
NSString *PROPERTY_SALES_RESPONSE_HTML_FILE_NAME = @"responseData2.html";
NSString *PROPERTY_SALES_DATA_ARRAY_FILE_NAME = @"PropertiesArray.plist";
NSString *PROPERTY_SALES_DATA_DICTIONARY_FILE_NAME = @"PropertiesDictionary.plist";
NSString *LOCATION_COORDINATES_MAP_DICTIONARY_FILE_NAME = @"LocationCoordinates.plist";

@interface PSDataController ()

@property (strong, nonatomic) NSMutableDictionary *postParams;

@end

@implementation PSDataController

- (void)fetchData
{
    ENTRY_LOG;
    [self invokeInitialRequest];
    EXIT_LOG;
}

- (void)invokeInitialRequest
{
    ENTRY_LOG;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
    [manager GET:requestURL
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             LogVerbose(@"ResponseObject: %@", responseObject);
             [self saveResponseHTML:responseObject toFile:INITIAL_REQUEST_RESPONSE_HTML_FILE_NAME];
             
             [self parsePropertySalesInitialRequest:responseObject];
             
             if([self.postParams count] > 0) {
                 LogDebug(@"Retrieved Parameters from the initial request: %@", self.postParams);
                 [self fetchPropertySalesInformation];
             } else {
                 LogError(@"%s: Response Data Parsing Issue", __PRETTY_FUNCTION__);
             }

      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          LogError(@"Error: %@", error);
      }];
    
    EXIT_LOG;
}

- (void)parsePropertySalesInitialRequest:(NSData *)responseData
{
    ENTRY_LOG;
    
    TFHpple *propertySalesParse = [TFHpple hppleWithHTMLData:responseData];
    
    self.postParams = [NSMutableDictionary dictionaryWithCapacity:14];
    
    [self parseInputElements:propertySalesParse];
    [self parseSelectElements:propertySalesParse];
    
    EXIT_LOG;
}

- (void)parseInputElements:(TFHpple *)propertySalesParse
{
    ENTRY_LOG;
    
    NSArray *propertyNodes = [propertySalesParse searchWithXPathQuery:@"//input"];
    
    for (TFHppleElement *element in propertyNodes) {
        NSString *elementId = [element objectForKey:@"id"];
        if(elementId != nil && ![elementId hasPrefix:@"GridView"] && ![elementId hasPrefix:@"btn"]) {
//        if(elementId != nil) {
            NSString *value = [element objectForKey:@"value"];
            
            if(value == nil) {
                value = @"";
            }
            
            [self.postParams setObject:value forKey:[element objectForKey:@"id"]];
        }
    }
    EXIT_LOG;
}

- (void)parseSelectElements:(TFHpple *)propertySalesParse
{
    ENTRY_LOG;
    
    NSArray *propertyNodes = [propertySalesParse searchWithXPathQuery:@"//select"];
    
    for (TFHppleElement *element in propertyNodes) {
        if([element objectForKey:@"id"] != nil) {
            NSArray *optionNode = [propertySalesParse searchWithXPathQuery:[NSString stringWithFormat:@"//select[@id='%@']/option[@selected='selected']", [element objectForKey:@"id"]]];
            
            NSString *value = [optionNode[0] objectForKey:@"value"];
            
            if(value == nil) {
                value = @"";
            }
            
            [self.postParams setObject:value forKey:[element objectForKey:@"id"]];
        }
    }
    
    //Extra parameters for next request
    [self.postParams setObject:@"ddlDate" forKey:@"__EVENTTARGET"];
    [self.postParams setObject:@"" forKey:@"__EVENTARGUMENT"];
    [self.postParams setObject:@"" forKey:@"__LASTFOCUS"];
    
    [self.postParams setObject:@"2/6/2014" forKey:@"ddlDate"];
    
    EXIT_LOG;
}

#pragma mark - Fetch Properties
- (void)fetchPropertySalesInformation
{
    ENTRY_LOG;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
//    for(NSString *key in self.postParams) {
//            [manager.requestSerializer setValue:self.postParams[key] forHTTPHeaderField:key];
//    }
    
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
    [manager POST:requestURL
       parameters:self.postParams
          success:^(NSURLSessionDataTask *task, id responseObject) {
              LogVerbose(@"ResponseObject: %@", responseObject);
              [self saveResponseHTML:responseObject toFile:PROPERTY_SALES_RESPONSE_HTML_FILE_NAME];

              [self parsePropertySalesInformation:responseObject];
              
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              LogError(@"Error: %@", error);
              
          }];
    
    
    EXIT_LOG;
}

- (void)parsePropertySalesInformation:(NSData *)responseData
{
    TFHpple *propertySalesParse = [TFHpple hppleWithHTMLData:responseData];
    NSUInteger totalNumberOfProperties = [self numberOfRecords:propertySalesParse];
    
    NSArray *headers = [self parseTableHeader:propertySalesParse];
    DDLogDebug(@"Headers: %@", headers);
    
    NSMutableArray *properties = [NSMutableArray array];
    
    if([headers count] > 0) {
        
        for(int j=2; j<totalNumberOfProperties; j++) {
//            NSArray *values = [self parseTableRowData:propertySalesParse forTheRowNumber:j];
            NSMutableDictionary *propertyDictionary = [self parseTableRowData:propertySalesParse
                                                         forTheRowNumber:j
                                                             withHeaders:headers];
            
//            if(values == nil || [values count] <= 0) {
//                LogError(@"Could parse the table data");
//            } else {
//                LogDebug(@"Property Row%d: %@", j, values);
//                LogDebug(@"Address: %@ %@", values[3], values[8]);
//            }
            
//            [properties addObject:values];
            [properties addObject:propertyDictionary];
        }
        
        if([properties count] > 0) {
            LogInfo(@"Property Sales are parsed successfully. Number of Properties: %u", [properties count]);
            LogDebug(@"Properties: %@", properties);
            [self savePropertiesToFile:properties];
        } else {
            LogError(@"There is some problem in parsing the Property Sales html response");
        }
    }
}

- (NSUInteger)numberOfRecords:(TFHpple *)propertySalesParse
{
    NSArray *propertyRecords = [propertySalesParse searchWithXPathQuery:@"//*[@id='GridView1']//tr"];
    LogDebug(@"Number of Available Properties - count: %d", [propertyRecords count]);
    
    return [propertyRecords count];
}

- (NSArray *)parseTableHeader:(TFHpple *)propertySalesParse
{
    NSArray *propertyNodes = [propertySalesParse searchWithXPathQuery:@"//*[@id='GridView1']//tr[1]/th/font/b"];
    NSMutableArray *headers = [NSMutableArray array];
    
    LogDebug(@"Number of Columns: %d", propertyNodes.count);
    
    for (TFHppleElement *element in propertyNodes) {
        [headers addObject:[[element firstChild] content]];
    }
    
    return headers;
}

- (NSArray *)parseTableRowData:(TFHpple *)propertySalesParse forTheRowNumber:(NSUInteger)rowNumber
{
    NSString *xpath = [NSString stringWithFormat:@"//*[@id='GridView1']/tr[%d]/td/font", rowNumber];
    NSArray *propertyNodes = [propertySalesParse searchWithXPathQuery:xpath];
    NSMutableArray *values = [NSMutableArray array];
    
    for (TFHppleElement *element in propertyNodes) {
        if([[element firstChild] content] != nil) {
            [values addObject:[[element firstChild] content]];
        } else {
            [values addObject:@""];
        }
        
    }
    
    return values;
}

- (NSMutableDictionary *)parseTableRowData:(TFHpple *)propertySalesParse forTheRowNumber:(NSUInteger)rowNumber withHeaders:(NSArray *)headers
{
    NSString *xpath = [NSString stringWithFormat:@"//*[@id='GridView1']/tr[%d]/td/font", rowNumber];
    NSArray *propertyNodes = [propertySalesParse searchWithXPathQuery:xpath];
    
    NSMutableDictionary *propertyDictionary = [NSMutableDictionary dictionary];
    
    int i = 0;
    
    for (TFHppleElement *element in propertyNodes) {
        id value = @"";
        
        if([[element firstChild] content] != nil) {
            value = [[element firstChild] content];
        }
        
        [propertyDictionary setObject:value forKey:headers[i]];
        i++;
    }
    
    return propertyDictionary;
}


#pragma mark - Save to Text File

- (void)saveResponseHTML:(NSData *)responseData toFile:(NSString *)fileName
{
    ENTRY_LOG;
    
    NSString *responseDataString  = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    LogVerbose(@"ResponseData: %@", responseDataString);

    NSString *path = [self filePathFor:fileName];
    NSError *error;
    BOOL succeed = [responseDataString writeToFile:path
                          atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (succeed){
        // Handle error here
        LogInfo(@"Successfully saved to %@", path);
    } else {
        LogError(@"Failed to Save to %@", path);
    }
    
    EXIT_LOG;
}

-(void)savePropertiesToFile:(NSArray *)propertiesArray
{
    ENTRY_LOG;
    
    NSString *path = [self filePathFor:PROPERTY_SALES_DATA_DICTIONARY_FILE_NAME];
    
    BOOL succeed = [propertiesArray writeToFile:path atomically:YES];
    if (succeed){
        // Handle error here
        LogInfo(@"Successfully saved to %@", path);
    } else {
        LogError(@"Failed to Save to %@", path);
    }
    
    EXIT_LOG;
}

-(void)saveLocationsMap:(NSDictionary *)locationCoordinatesMap
{
    ENTRY_LOG;
    
    NSString *path = [self filePathFor:LOCATION_COORDINATES_MAP_DICTIONARY_FILE_NAME];
    
    BOOL succeed = [locationCoordinatesMap writeToFile:path atomically:YES];
    if (succeed){
        // Handle error here
        LogInfo(@"Successfully saved to %@", path);
    } else {
        LogError(@"Failed to Save to %@", path);
    }
    
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
- (NSArray *)getProperties
{
    ENTRY_LOG;
    
    NSString *path = [self filePathFor:PROPERTY_SALES_DATA_DICTIONARY_FILE_NAME];
    
    NSArray *propertiesArray = [NSArray arrayWithContentsOfFile:path];

    EXIT_LOG;
    
    return propertiesArray;

}

- (NSDictionary *)getLocationCoordinatesMap
{
    ENTRY_LOG
    
    NSString *path = [self filePathFor:LOCATION_COORDINATES_MAP_DICTIONARY_FILE_NAME];
    
    NSDictionary *locationCoordinatesMap = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return locationCoordinatesMap;
    
    EXIT_LOG
}

@end
