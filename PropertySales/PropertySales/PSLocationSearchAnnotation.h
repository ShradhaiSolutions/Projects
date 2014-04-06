//
//  PSLocationSearchAnnotation.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 3/20/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PSLocationSearchAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic)   CLLocationCoordinate2D coordinate;
@property (copy, nonatomic)     NSString *title;
@property (copy, nonatomic)     NSString *subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@end
