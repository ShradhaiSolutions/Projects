//
//  PSGoogleMapsHandler.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/21/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSGoogleMapsManager : NSObject

- (BOOL)isGoogleMapsAppInstalled;
- (void)openGoogleMapsWithDestinationAddress:(NSString *)address;
- (void)openGoogleMapsWithDestinationLatitude:(double)latitude longitude:(double)longitude;

@end
