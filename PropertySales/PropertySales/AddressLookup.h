//
//  AddressLookup.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/8/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Property;

@interface AddressLookup : NSManagedObject

@property (nonatomic, retain) NSString * lookupAddress;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *relationship;
@end

@interface AddressLookup (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(Property *)value;
- (void)removeRelationshipObject:(Property *)value;
- (void)addRelationship:(NSSet *)values;
- (void)removeRelationship:(NSSet *)values;

@end
