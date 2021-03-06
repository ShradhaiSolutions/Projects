//
//  PSPropertySaleDataParser.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/15/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertySaleDataParser.h"
#import "TFHpple.h"

@implementation PSPropertySaleDataParser

- (RACSignal *)parsePropertySalesInformation:(NSData *)responseData
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogDebug(@"Parsing the Property Sale data response - Start");
        
        TFHpple *propertySalesParse = [TFHpple hppleWithHTMLData:responseData];
        NSUInteger totalNumberOfProperties = [self numberOfRecords:propertySalesParse];
        
        //TODO: Optimize
        static NSArray *headers;
        
        if([headers count] == 0) {
            LogDebug(@"Parsing the Table Header");
            headers = [self parseTableHeader:propertySalesParse];
        }
        
        NSMutableArray *properties = [NSMutableArray array];
        
        if([headers count] > 0) {
            for(int j=2; j<totalNumberOfProperties; j++) {
                NSMutableDictionary *propertyDictionary = [self parseTableRowData:propertySalesParse
                                                                  forTheRowNumber:j
                                                                      withHeaders:headers];
                [properties addObject:propertyDictionary];
            }
            
            if([properties count] > 0) {
                LogInfo(@"Property Sales are parsed successfully. Number of Properties: %lu", (unsigned long)[properties count]);
                LogVerbose(@"Properties: %@", properties);
            } else {
                LogError(@"There is some problem in parsing the Property Sales html response");
            }
        }
        
        LogDebug(@"Parsing the Property Sale data response - End");
        
        [subscriber sendNext:[properties copy]];
        [subscriber sendCompleted];
        
        properties = nil;
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

- (NSUInteger)numberOfRecords:(TFHpple *)propertySalesParse
{
    NSArray *propertyRecords = [propertySalesParse searchWithXPathQuery:@"//*[@id='GridView1']//tr"];
    LogDebug(@"Number of Available Properties - count: %lu", (unsigned long)[propertyRecords count]);
    
    return [propertyRecords count];
}

- (NSArray *)parseTableHeader:(TFHpple *)propertySalesParse
{
    NSArray *propertyNodes = [propertySalesParse searchWithXPathQuery:@"//*[@id='GridView1']//tr[1]/th"];
    NSMutableArray *headers = [NSMutableArray array];
    
    LogVerbose(@"Number of Columns: %lu", (unsigned long)propertyNodes.count);
    
    for (TFHppleElement *element in propertyNodes) {
        [headers addObject:[[element firstChild] content]];
    }
    
    return headers;
}

- (NSMutableDictionary *)parseTableRowData:(TFHpple *)propertySalesParse forTheRowNumber:(NSUInteger)rowNumber withHeaders:(NSArray *)headers
{
    NSString *xpath = [NSString stringWithFormat:@"//*[@id='GridView1']/tr[%lu]/td", (unsigned long)rowNumber];
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

@end
