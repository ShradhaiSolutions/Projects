//
//  PSFileManager.h
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/13/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kPropertyMetaDataResponseFileName = @"PropertyMetaData.html";
static NSString * const kPropertySaleDataResponseFileName = @"PropertySaleData";
static NSString * const kPropertySalesArrayFileName = @"PropertiesArray.plist";
static NSString * const kAddressToGeocodeMappingDictionaryFileName = @"AddressToGeocodeMapping.plist";

@interface PSFileManager : NSObject

- (RACSignal *)saveResponseHTML:(NSData *)responseData toFile:(NSString *)fileName;
- (void)savePropertiesToFile:(NSArray *)propertiesArray;
- (void)saveAddressToGeocodeMappingDictionaryToFile:(NSDictionary *)addressToGeocodeMapping;

- (NSArray *)getProperties;
- (NSDictionary *)getAddressToGeocodeMappingCache;

@end
