//
//  PSDataManager.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSDataManager : NSObject

@property (strong, nonatomic) NSArray *properties;

- (void)fetchData;

- (NSArray *)properiesForSale;
- (NSArray *)getSaleDates;
- (NSArray *)getSaleDatesStrings;

@end
