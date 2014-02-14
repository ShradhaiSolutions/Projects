//
//  PSSearchResultsViewModel.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/12/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSSearchResultsViewModel : NSObject

@property (strong, nonatomic) NSString *searchString;

@property (strong, nonatomic) NSArray *properties;
@property (strong, nonatomic) NSArray *propertiesFromSearchResult;

- (void)setup;

@end
