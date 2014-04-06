//
//  PSDataCommunicator.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Social Ads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SADataCommunicator : NSObject

- (RACSignal *)fetchEventsData;

@end
