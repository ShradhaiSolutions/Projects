//
//  PSDataController.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/3/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSDataController : NSObject

- (void)fetchData;
- (NSArray *)getProperties;

-(void)saveLocationsMap:(NSDictionary *)locationCoordinatesMap;
- (NSDictionary *)getLocationCoordinatesMap;

- (NSArray *)properiesForSale;

@end
