//
//  SADataParser.h
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 3/18/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SADataParser : NSObject

- (RACSignal *)parseEventsInformation:(NSData *)responseData;

@end
