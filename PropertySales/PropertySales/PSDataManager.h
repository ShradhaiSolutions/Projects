//
//  PSDataManager.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

extern double kDataFetchFailure;
extern double kDataFetchSuccess;

@interface PSDataManager : NSObject

@property (strong, nonatomic) NSArray *properties;
@property (strong, nonatomic) NSNumber *dataFetchProgress;

+ (instancetype)sharedInstance;
    
- (NSArray *)properiesForSale;
- (NSArray *)getSaleDates;
- (NSArray *)getSaleDatesStrings;

- (void)fetchData;
- (void)forceDataFetch;

@end
