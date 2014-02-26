//
//  PSDataParser.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/14/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertyMetadataDataParser.h"
#import "TFHpple.h"

@implementation PSPropertyMetadataDataParser

- (RACSignal *)parsePropertySalesInitialRequest:(NSData *)responseData
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogDebug(@"Parsing the Property Metadata response - Start");
        
        TFHpple *parsedResponseObject = [TFHpple hppleWithHTMLData:responseData];
        
        NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionaryWithCapacity:14];
        
        [self parseInputElements:parsedResponseObject into:paramsDictionary];

        [self parseSelectElements:parsedResponseObject into:paramsDictionary];

        [self parseSaleDates:parsedResponseObject into:paramsDictionary];
        
        LogDebug(@"Parsing the Property Metadata response - Completed");
        
        [subscriber sendNext:[paramsDictionary copy]];
        [subscriber sendCompleted];
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

- (void)parseInputElements:(TFHpple *)parsedResponseObject into:(NSMutableDictionary *)paramsDictionary
{
    ENTRY_LOG;
    
    NSArray *propertyNodes = [parsedResponseObject searchWithXPathQuery:@"//input"];
    
    for (TFHppleElement *element in propertyNodes) {
        NSString *elementId = [element objectForKey:@"id"];
        if(elementId != nil && ![elementId hasPrefix:@"GridView"] && ![elementId hasPrefix:@"btn"]) {
            //        if(elementId != nil) {
            NSString *value = [element objectForKey:@"value"];
            
            if(value == nil) {
                value = @"";
            }
            
            [paramsDictionary setObject:value forKey:[element objectForKey:@"id"]];
        }
    }
    
    EXIT_LOG;
}

- (void)parseSelectElements:(TFHpple *)parsedResponseObject into:(NSMutableDictionary *)paramsDictionary
{
    ENTRY_LOG;
    
    NSArray *propertyNodes = [parsedResponseObject searchWithXPathQuery:@"//select"];
    
    for (TFHppleElement *element in propertyNodes) {
        if([element objectForKey:@"id"] != nil) {
            NSArray *optionNode = [parsedResponseObject searchWithXPathQuery:[NSString stringWithFormat:@"//select[@id='%@']/option[@selected='selected']", [element objectForKey:@"id"]]];
            
            NSString *value = [optionNode[0] objectForKey:@"value"];
            
            if(value == nil) {
                value = @"";
            }
            
            [paramsDictionary setObject:value forKey:[element objectForKey:@"id"]];
        }
    }
    
    //Extra parameters for next request
    [paramsDictionary setObject:@"ddlDate" forKey:@"__EVENTTARGET"];
    [paramsDictionary setObject:@"" forKey:@"__EVENTARGUMENT"];
    [paramsDictionary setObject:@"" forKey:@"__LASTFOCUS"];
    
//    [paramsDictionary setObject:@"2/6/2014" forKey:@"ddlDate"];
    
    EXIT_LOG;
}

- (void)parseSaleDates:(TFHpple *)parsedResponseObject into:(NSMutableDictionary *)paramsDictionary
{
    ENTRY_LOG;
    
    NSMutableArray *saleDates = [NSMutableArray array];
    
    NSArray *propertyNodes = [parsedResponseObject searchWithXPathQuery:@"//select[@id='ddlDate']/option"];
    
    for (TFHppleElement *element in propertyNodes) {
        NSString *saleDate = [element objectForKey:@"value"];
        
        if(saleDate != nil && ![saleDate isEqualToString:@""]) {
            LogDebug(@"SaleDate: %@", saleDate);
            [saleDates addObject:saleDate];
        }
    }
    
    [paramsDictionary setObject:[saleDates copy] forKey:@"SaleDatesArray"];
    
    EXIT_LOG;
}

@end
