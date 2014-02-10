//
//  Property+MKAnnotations.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/9/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "Property+MKAnnotations.h"
#import "AddressLookup+Methods.h"
#import <AddressBook/AddressBook.h>

@implementation Property (MKAnnotations)

- (NSString *)title {
    return self.attyName;
}

- (NSString *)subtitle {
    
    return [NSString stringWithFormat:@"Appraisal: %@, MinBid: %@", self.appraisal, self.minBid];
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [self.addressLookup.latitude doubleValue];
    theCoordinate.longitude = [self.addressLookup.longitude doubleValue];
    
    return theCoordinate;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : self.address};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end
