//
//  PSLocationManager.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/4/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef void (^PSLocationSearchCompletionBlock)(NSArray *placemarks);

@interface PSLocationManager : NSObject

@property (strong, nonatomic) NSArray *propertiesArray;

- (void)getCoordinates;
-(NSArray *)createPropertiesModel;
- (void)convertAddressToCoordinate:(NSString *)address withCompletion:(PSLocationSearchCompletionBlock)completion;

@end
