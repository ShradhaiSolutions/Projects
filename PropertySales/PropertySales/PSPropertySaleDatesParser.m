//
//  PSPropertySaleDatesParser.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 3/11/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSPropertySaleDatesParser.h"

#import "TFHpple.h"

static NSUInteger const kMaxNumberOfSaleDates = 5;

@implementation PSPropertySaleDatesParser

- (RACSignal *)parsePropertySaleDatesResponse:(NSData *)responseData
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
        
        parsedResponseObject = nil;
        
        NSArray *saleDates = [paramsDictionary objectForKey:@"SaleDatesArray"];
        
        if([saleDates count] <= 0) {
            [subscriber sendError:[NSError errorWithDomain:@"PropertyMetaDataParseNoSaleDates" code:100 userInfo:nil]];
        } else {
            LogDebug(@"Parsing the Property Metadata response - Completed");
            
            [subscriber sendNext:[paramsDictionary copy]];
            [subscriber sendCompleted];
        }
        
        
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
    
    propertyNodes = nil;
    
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
    
    propertyNodes = nil;
    
    //Extra parameters for next request
    [paramsDictionary setObject:@"ddlDate" forKey:@"__EVENTTARGET"];
    [paramsDictionary setObject:@"" forKey:@"__EVENTARGUMENT"];
    [paramsDictionary setObject:@"" forKey:@"__LASTFOCUS"];
    
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
    
    propertyNodes = nil;
    
    //Todo: make this configurable
    //Fetch the properties for only first five sale dates
    if([saleDates count] > kMaxNumberOfSaleDates) {
        [paramsDictionary setObject:[[saleDates copy] subarrayWithRange:NSMakeRange(0, kMaxNumberOfSaleDates)] forKey:@"SaleDatesArray"];
    } else {
        [paramsDictionary setObject:[saleDates copy] forKey:@"SaleDatesArray"];
    }
    
    
    EXIT_LOG;
}

@end
