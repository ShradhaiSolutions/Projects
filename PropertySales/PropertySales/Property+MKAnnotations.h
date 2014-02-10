//
//  Property+MKAnnotations.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "Property+Methods.h"
#import <MapKit/MapKit.h>

@interface Property (MKAnnotations) <MKAnnotation>

- (MKMapItem*)mapItem;

@end
