//
//  PSLocationSearchResultsViewController.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 3/23/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseViewController.h"
#import <MapKit/MapKit.h>

@protocol PSLocationSearchDelegate <NSObject>
- (void)addLocationSearchAnnotation:(CLPlacemark *)placemark;
@end


@interface PSLocationSearchResultsViewController : PSBaseViewController

@property (copy, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) id<PSLocationSearchDelegate> delegate;

@end

