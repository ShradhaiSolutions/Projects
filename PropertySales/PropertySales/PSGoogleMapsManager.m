//
//  PSGoogleMapsHandler.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/21/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSGoogleMapsManager.h"

@implementation PSGoogleMapsManager

- (BOOL)isGoogleMapsAppInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
}

- (void)openGoogleMapsWithDestinationAddress:(NSString *)address
{
    if([self isGoogleMapsAppInstalled]) {
        NSString *directionsUrl = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%@&directionsmode=driving&zoom=17", [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        LogDebug(@"Opening the Google maps with url: %@", directionsUrl);
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:directionsUrl]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App not installed"
                                                        message:@"Please install Google Maps App"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)openGoogleMapsWithDestinationLatitude:(double)latitude longitude:(double)longitude
{
    if([self isGoogleMapsAppInstalled]) {
        NSString *directionsUrl = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f&directionsmode=driving&zoom=17", latitude, longitude];
        
        LogDebug(@"Opening the Google maps with url: %@", directionsUrl);
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:directionsUrl]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App not installed"
                                                        message:@"Please install Google Maps App"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


@end
