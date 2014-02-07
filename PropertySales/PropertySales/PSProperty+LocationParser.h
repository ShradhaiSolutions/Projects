//
//  PSProperty+LocationParser.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/6/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSProperty.h"

@interface PSProperty (LocationParser)

- (RACSignal *)convertAddressToCoordinate;

@end
