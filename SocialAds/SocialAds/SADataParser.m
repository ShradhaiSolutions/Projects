//
//  SADataParser.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 3/18/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import "SADataParser.h"
#import "SAEvent.h"

@interface SADataParser ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation SADataParser

- (id)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }
    return self;
}

- (RACSignal *)parseEventsInformation:(NSData *)responseData
{
    ENTRY_LOG;
    
    EXIT_LOG;
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogDebug(@"Parsing the Events data response - Start");
        
        NSError *err;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&err];
        
        NSArray *eventsData = [jsonObject objectForKey:@"Events"];
        NSMutableArray *events = [NSMutableArray arrayWithCapacity:[eventsData count]];
        
        if(eventsData == nil) {
            DDLogError(@"Error Parsing Response Data: %@", err);
            [subscriber sendError:err];
        } else {
            for(NSDictionary *eventData in eventsData) {
                LogDebug(@"Event: %@", eventData);
                
                SAEvent *event = [SAEvent initWithTitle:[eventData objectForKey:@"eventDescription"]
                                               location:[eventData objectForKey:@"address1"]
                                                   date:[self.dateFormatter dateFromString:[eventData objectForKey:@"startDate"]]
                                            eventSource:[eventData objectForKey:@"sourceDescription"]];
                
                [events addObject:event];
            }
            
            LogDebug(@"Parsing the Events data response - End");
            
            [subscriber sendNext:[events copy]];
            [subscriber sendCompleted];
        }
        
        return nil;
    }] doError:^(NSError *error) {
        LogError(@"%@",error);
    }];
}

@end
