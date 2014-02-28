//
//  PSApplicationContext.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/27/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSApplicationContext : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) NSString *appVersionNumber;
@property (strong, nonatomic) NSString *buildNumber;

@end
