//
//  PSAppleMapsManager.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/21/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSAppleMapsManager.h"

@implementation PSAppleMapsManager

- (void)openGoogleMapsWithDestinationLatitude:(double)latitude longitude:(double)longitude
{
    NSString *directionsUrl = [NSString stringWithFormat:@"http://maps.apple.com?saddr=currentLocation&daddr=%f,%f&t=driving&zoom=17", latitude, longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:directionsUrl]];
}

@end
