//
//  PSLocationUtils.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/4/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSLocationUtils : NSObject

@property (strong, nonatomic) NSArray *propertiesArray;

- (void)getCoordinates;

@end
