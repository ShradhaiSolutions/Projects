//
//  PSPropertiesMapViewController.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseViewController.h"
#import <MapKit/MapKit.h>

@interface PSPropertiesMapViewController : PSBaseViewController <MKMapViewDelegate>

@property(copy, nonatomic) NSArray *properties;

@end
