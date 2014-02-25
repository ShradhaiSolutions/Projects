//
//  PSPropertyAnnotation.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/18/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Property+Methods.h"

@interface PSPropertyAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) Property *property;

@property (assign, nonatomic)   CLLocationCoordinate2D coordinate;
@property (copy, nonatomic)     NSString *title;
@property (copy, nonatomic)     NSString *subtitle;

- (void)setPropertyDetails:(Property *)property;

@end
