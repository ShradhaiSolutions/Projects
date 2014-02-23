//
//  PSTestViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/1/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSTestViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "PSLocationManager.h"
#import "PSProperty+LocationParser.h"

#import "Property+Methods.h"
#import "AddressLookup.h"

#import "PSDataImporter.h"

#import "PSDataManager.h"

#import "PSFileManager.h"

#import "PSLocationParser.h"


@interface PSTestViewController ()

@end

@implementation PSTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    PSDataManager *dataManager = [[PSDataManager alloc] init];
//    [dataManager fetchData];
    
//    [AddressLookup MR_truncateAll];
//    [Property MR_truncateAll];
//
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    NSArray *properties = [Property MR_findAll];
    LogDebug(@"Properties: %ld", [properties count]);

    NSArray *addressLookup = [AddressLookup MR_findAll];
    LogDebug(@"AddressLookup: %ld", [addressLookup count]);

    
//    PSFileManager *fileManager = [[PSFileManager alloc] init];
//
//    PSLocationParser *locationParser = [[PSLocationParser alloc] init];
//    locationParser.properties = [fileManager getProperties];
//    locationParser.addressToGeocodeMappingDictionary = [[fileManager getAddressToGeocodeMappingCache] mutableCopy];
    
//    [locationParser getCoordinates];
    
//    for(NSMutableDictionary *property in locationParser.properties) {
//        LogInfo(@"CaseNo: %@", [property objectForKey:@"CaseNO"]);
//    }
    
//    LogInfo(@"Hash of Properties: %lu", [[locationParser.properties description] hash]);
//    LogInfo(@"Hash Value: %lu", [@"Dhana" hash]);
//    LogInfo(@"Hash Value: %lu", [[@"Dhana" copy] hash]);
//    LogInfo(@"Hash Value: %lu", [[@"Dhana" mutableCopy] hash]);
    

    
//    [self testRACSignals];
//    [self testSignalChain];
//    [self testSignalMap];
//    [self testMultipleSignalsWithMerge];
//    [self testChainingIndependentOperations];
//    [self testChainingDependentOperations];
//    [self testChainingDependentOperationsWithErrors];
//    [self testChainingInDependentOperationsWithErrors];
}

- (void)testRACSignals
{
    [[self signal1] subscribeNext:^(id x) {
        LogInfo(@"NextValue: %@", x);
    } error:^(NSError *error) {
        LogError(@"Error: %@", error);
    } completed:^{
        LogInfo(@"Completed");
    }];
}

/*
 * Summary: doNext (explicit side effect) -> subscribeNext -> doComplete -> completed
 */

/*
 * Output Log
 *      Executing Signal1   --> Signal Block Start
 *      NextValue: Signal1  --> subscribeNext block (following sendNext)
 *      About to complete Signal1   --> doComplete block of Signal
 *      Completed                   --> completed block of signal subscription
 *      Completed Execution Block: Signal1  --> Signal Block End
 */
- (void)testSingleRACSignal
{
    [[self signal1] subscribeNext:^(id x) {
        LogInfo(@"NextValue: %@", x);
    } error:^(NSError *error) {
        LogError(@"Error: %@", error);
    } completed:^{
        LogInfo(@"Completed");
    }];
}

/*
 * 1. flattenMap on a signal doesn't subscribe automatically
 * 2. the return signal from flattenMap block is executed without subscription
 * 3. flattenMap block is executed for every next value and it is executed synchronously (until explicit queuing is done)
 * 4. Signal2 block is executed synchronously to Signal1  (blocks Signal1 exeuction until Signal2 block is completed).
 * 5. subscribeNext, error and complete blocks will be executed according to signal2 events (not signal1)
 */

- (void)testSignalChain
{
    [[[self signal1]
     flattenMap:^RACStream *(id value) {
        LogInfo(@"flattenMap: %@", value);
        return [self signal2];
     }]subscribeNext:^(id x) {
         LogInfo(@"NextValue: %@", x);
     } error:^(NSError *error) {
         LogError(@"Error: %@", error);
     } completed:^{
         LogInfo(@"Completed");
     }];
}

/*
 * This is similar to flattenMap but just does the value transformation (can't be used for signal chaining)
 *
 */

- (void)testSignalMap
{
    [[[self signal1]
      map:^id(id value) {
          LogDebug(@"Transforming the value");
          return @1;
      }] subscribeNext:^(id x) {
          LogInfo(@"NextValue: %@", x);
      } error:^(NSError *error) {
          LogError(@"Error: %@", error);
      } completed:^{
          LogInfo(@"Completed");
      }];
}


- (void)testMultipleSignalsWithMerge
{
    NSArray *sequence = @[[self signal1], [self signal2]];
    
    [[RACSignal
      merge:sequence]
     subscribeNext:^(id x) {
         LogInfo(@"NextValue: %@", x);
     } error:^(NSError *error) {
         LogError(@"Error: %@", error);
     } completed:^{
         LogInfo(@"Completed");
     }];
}


- (void)testChainingIndependentOperations
{
    NSArray *sequence = @[[[self signal1] subscribeOn:[RACScheduler scheduler]],
                           [[self signal2] subscribeOn:[RACScheduler scheduler]]];
    
    [[RACSignal
      merge:[sequence reverseObjectEnumerator]]
     subscribeNext:^(id x) {
         LogInfo(@"NextValue: %@", x);
     } error:^(NSError *error) {
         LogError(@"Error: %@", error);
     } completed:^{
         LogInfo(@"Completed");
     }];
}

- (void)testChainingDependentOperations
{
    [[[self signal2]
      flattenMap:^RACStream *(id value) {
          return [self signal1];
      }] subscribeNext:^(id x) {
          LogInfo(@"NextValue: %@", x);
      } error:^(NSError *error) {
          LogError(@"Error: %@", error);
      } completed:^{
          LogInfo(@"Completed");
      }];
}


- (void)testChainingDependentOperationsWithErrors
{
    [[[self signal1WithError]
      flattenMap:^RACStream *(id value) {
          return [self signal2];
      }] subscribeNext:^(id x) {
          LogInfo(@"NextValue: %@", x);
      } error:^(NSError *error) {
          LogError(@"Error: %@", error);
      } completed:^{
          LogInfo(@"Completed");
      }];
}

- (void)testChainingInDependentOperationsWithErrors
{
    NSArray *sequence = @[[[self signal2] subscribeOn:[RACScheduler scheduler]],
                          [[self signal1WithError] subscribeOn:[RACScheduler scheduler]]];
    
    [[RACSignal
      merge:[sequence reverseObjectEnumerator]]
     subscribeNext:^(id x) {
         LogInfo(@"NextValue: %@", x);
     } error:^(NSError *error) {
         LogError(@"Error: %@", error);
     } completed:^{
         LogInfo(@"Completed");
     }];
}

- (RACSignal *)signal1
{
    NSString *signalName = @"Signal1";
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogInfo(@"Executing %@", signalName);
        
        [subscriber sendNext:signalName];
        
        [subscriber sendNext:@"Signal1 NextValue2"];
        
        [subscriber sendCompleted];

        LogInfo(@"Completed Execution Block: %@", signalName);

        return nil;
    }] doCompleted:^{
        LogInfo(@"About to complete %@", signalName);
    }];
}

- (RACSignal *)signal1WithError
{
    NSString *signalName = @"Signal1";
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogInfo(@"Executing %@", signalName);
        
        [subscriber sendNext:signalName];
        
        [subscriber sendNext:@"Signal1 NextValue2"];
        
        [subscriber sendError:nil];
        
        LogInfo(@"Completed Execution Block: %@", signalName);
        
        return nil;
    }] doCompleted:^{
        LogInfo(@"About to complete %@", signalName);
    }];
}

- (RACSignal *)signal2
{
    NSString *signalName = @"Signal2";
    
    return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogInfo(@"Executing %@", signalName);
        
        [subscriber sendNext:signalName];

        [subscriber sendCompleted];

        LogInfo(@"Completed Execution Block: %@", signalName);
        
        return nil;
    }] doNext:^(id x) {
        LogError(@"Executing explicit doNext with value: %@", x);
    }] doCompleted:^{
        LogInfo(@"About to complete %@", signalName);
    }];
}

- (RACSignal *)signal1Transform:(NSString *)name
{
    NSString *signalName = @"Signal1Transform";
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogInfo(@"Executing %@", signalName);
        
        [subscriber sendNext:@1];
        
        [subscriber sendCompleted];
        
        LogInfo(@"Completed Execution Block: %@", signalName);
        
        return nil;
    }] doCompleted:^{
        LogInfo(@"About to complete %@", signalName);
    }];
}

- (RACSignal *)signal2Transform:(NSString *)name
{
    NSString *signalName = @"Signal2Transform";
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogInfo(@"Executing %@", signalName);
        
        [subscriber sendNext:@2];
        
        [subscriber sendCompleted];
        
        LogInfo(@"Completed Execution Block: %@", signalName);
        
        return nil;
    }] doCompleted:^{
        LogInfo(@"About to complete %@", signalName);
    }];
}

- (void)dataImport
{
    PSDataImporter *dataImporter = [[PSDataImporter alloc] init];
    [[dataImporter setupData] subscribeError:^(NSError *error) {
        LogError(@"Error while importing the data: %@",error);
    } completed:^{
        NSArray *properties = [Property MR_findAll];
        LogDebug(@"Properties: %@", properties);
    }];
}

- (void)testCoreDataImportForProperty
{
    __block NSArray *data = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]
                                                                             pathForResource:@"PropertiesDictionary"
                                                                             ofType:@"plist"] ];
    //    NSLog(@"Data: %@", data);
    
    //    AddressLookup *addressLookup = [AddressLookup MR_createEntity];
    //    addressLookup.lookupAddress = @"Test";
    //    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
    //        if(success) {
    //            LogInfo(@"AddressLookup data is successfully saved");
    //        } else {
    //            LogError(@"Error while saving the AddressLookup data: %@", error);
    //        }
    //    }];
    
//    NSArray *a = [Property MR_findAll];
//    NSLog(@"From CoreData: %@", a);
    
    [AddressLookup MR_truncateAll];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        
        for (NSDictionary *dict in data) {
            Property *property = [Property MR_createInContext:localContext];
            property.address = dict[@"Address"];
            property.appraisal = dict[@"Appraisal"];
            property.attyName = dict[@"AttyName"];
            property.attyPhone = dict[@"AttyPhone"];
            property.caseNo = dict[@"CaseNO"];
            property.minBid = dict[@"MinBid"];
            property.name = dict[@"Name"];
            property.plaintiff = dict[@"Plaintiff"];
            property.saleData = [formatter dateFromString:dict[@"SaleDate"]];
            property.township = dict[@"Township"];
            property.wd = dict[@"WD"];
            property.lookupAddress = [NSString stringWithFormat:@"%@ %@ OH", dict[@"Address"], dict[@"Township"]];
        }
        
        [localContext MR_saveToPersistentStoreAndWait];
    } completion:^(BOOL success, NSError *error) {
        NSArray *b = [AddressLookup MR_findAll];
        NSLog(@"AddressLookup from CoreData: %@", b);
        
        NSArray *a = [Property MR_findAll];
        NSLog(@"From CoreData: %@", a);
    }];
}

- (void)testCoreDataImport
{
    __block NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                                     pathForResource:@"LocationCoordinates"
                                                                     ofType:@"plist"] ];
//    NSLog(@"Data: %@", data);
    
//    AddressLookup *addressLookup = [AddressLookup MR_createEntity];
//    addressLookup.lookupAddress = @"Test";
//    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
//        if(success) {
//            LogInfo(@"AddressLookup data is successfully saved");
//        } else {
//            LogError(@"Error while saving the AddressLookup data: %@", error);
//        }
//    }];
    
    NSArray *a = [AddressLookup MR_findAll];
    NSLog(@"From CoreData: %@", a);
    
    [AddressLookup MR_truncateAll];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        for (NSString *key in data) {
            NSDictionary *coordinateDictionary = [data objectForKey:key];
            
//            LogDebug(@"Key: %@", key);
            
            AddressLookup *addressLookup = [AddressLookup MR_createInContext:localContext];
            addressLookup.lookupAddress = key;
            addressLookup.latitude = coordinateDictionary[@"lat"];
            addressLookup.longitude = coordinateDictionary[@"long"];
        }
        
        [localContext MR_saveToPersistentStoreAndWait];
    } completion:^(BOOL success, NSError *error) {
//        if(success) {
//            LogInfo(@"AddressLookup data is successfully saved");
//        } else {
//            LogError(@"Error while saving the AddressLookup data: %@", error);
//        }
        
        NSArray *a = [AddressLookup MR_findAll];
        NSLog(@"From CoreData: %@", a);
    }];
}

- (void)buildRelationships
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *properties = [Property MR_findAllInContext:localContext];
        
        for (Property *property in properties) {
            property.addressLookup = [AddressLookup MR_findFirstByAttribute:@"lookupAddress"
                                                                  withValue:[property getAddress]
                                                                  inContext:localContext];
        }
        
        [localContext MR_saveToPersistentStoreAndWait];
    }];
}

- (void)testPropertyParsing
{
    ENTRY_LOG;
    
    PSLocationManager *locationManager = [[PSLocationManager alloc] init];

    __block NSArray *propertiesModel = [locationManager createPropertiesModel];
    LogInfo(@"Total number of properties: %lu", [propertiesModel count]);
//    LogInfo(@"Properties Model: %@", propertiesModel);
    
    RACSignal *propertiesSignal = propertiesModel.rac_sequence.signal;
    
//    RACSignal *propertiesSignal = [propertiesModel subarrayWithRange:NSMakeRange(0, 60)].rac_sequence.signal;
    
    [[propertiesSignal
      flattenMap:^(PSProperty *property) {
          return [property convertAddressToCoordinate];
      }]
     subscribeError:^(NSError *error) {
        LogError(@"Error: %@", error);
     } completed:^{
         LogInfo(@"Properties Model: %@", propertiesModel);
         LogInfo(@"All locations are retrieved");
         int numberOfLocationsInError = [self printSummary:propertiesModel];
         
         if(numberOfLocationsInError > 0) {
             
             double delayInSeconds = 60.0;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 [self parseAddresses:propertiesModel];
             });
             
             
         }
     }];
     
    
    EXIT_LOG;

}

- (int)printSummary:(NSArray *)properties
{
    int numberOfMultiLocations = 0;
    int numberOfSingleLocations = 0;
    int numberOfLocationsNotFound = 0;
    int numberOfLocationsInError = 0;
    
    for (PSProperty *property in properties) {
        switch (property.addressType) {
            case MultipleLocations:
                numberOfMultiLocations++;
                break;
            case SingleLocation:
                numberOfSingleLocations++;
                break;
            case NotFound:
                numberOfLocationsNotFound++;
                break;
            case Error:
                numberOfLocationsInError++;
                break;
        }
    }
    
    LogInfo(@"Number Of Multiple Locations: %u\n"
             "Number of Single Locations: %u \n"
            "Number of Locations Not Found: %u \n"
            "Number of Locations In Error: %u \n",
            numberOfMultiLocations, numberOfSingleLocations, numberOfLocationsNotFound, numberOfLocationsInError);
    
    return numberOfLocationsInError;
}

- (NSDictionary *)coordinateToDictionary:(CLLocationCoordinate2D)coordinate
{
    NSNumber *lat = [NSNumber numberWithDouble:coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:coordinate.longitude];

    NSDictionary *coordinateDictionary = @{@"lat":lat,@"long":lon};
    return coordinateDictionary;
}

- (CLLocationCoordinate2D)dictionaryToCoordinate:(NSDictionary *)coordinateDictionary
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[coordinateDictionary objectForKey:@"lat"] doubleValue];
    coordinate.latitude = [[coordinateDictionary objectForKey:@"long"] doubleValue];
    
    return coordinate;
}

- (void)parseAddresses:(NSArray *)propertiesModel
{
//    RACSignal *propertiesSignal = propertiesModel.rac_sequence.signal;
    
    //    RACSignal *propertiesSignal = [propertiesModel subarrayWithRange:NSMakeRange(0, 60)].rac_sequence.signal;
    
    [[[propertiesModel.rac_sequence.signal filter:^BOOL(PSProperty *property) {
        if(property.addressType == Error) {
            return YES;
        } else {
            return NO;
        }
    }] flattenMap:^RACStream *(PSProperty *property) {
        return [property convertAddressToCoordinate];
    }] subscribeError:^(NSError *error) {
        LogError(@"Error: %@", error);
    } completed:^{
//        int numberOfLocationsInError = [self printSummary:propertiesModel];
        [self printSummary:propertiesModel];
//        [self saveLocationMapping:propertiesModel];
    }];
}

- (void)testMultipleProperties
{

    PSProperty *property1 = [[PSProperty alloc] init];
    property1.address = @"2540 HIGHWOOD LN";
    property1.township = @"COLERAIN TWSP";

    PSProperty *property2 = [[PSProperty alloc] init];
    property2.address = @"164 DORSEY ST";
    property2.township = @"CINTI";

    NSMutableArray *properties = [NSMutableArray array];
    [properties addObject:property1];
    [properties addObject:property2];
    
    RACSignal *propertiesSignal = properties.rac_sequence.signal;

    [[propertiesSignal
      flattenMap:^(PSProperty *property) {
          return [property convertAddressToCoordinate];
      }]
     subscribeCompleted:^{
         NSLog(@"All locations are retrieved");
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)crashMe:(id)sender {
    //    [[Crashlytics sharedInstance] crash];
    
    DDLogVerbose(@"%s Verbose ", __PRETTY_FUNCTION__);
    DDLogDebug(@"%s Debug ", __PRETTY_FUNCTION__);
    DDLogInfo(@"%s Info ", __PRETTY_FUNCTION__);
    DDLogWarn(@"%s Warn ", __PRETTY_FUNCTION__);
    DDLogError(@"%s Error ", __PRETTY_FUNCTION__);
    
//    NSString *string = nil;
//    
//    NSDictionary *diction = @{@"key":@"value",
//                              @"key1":string};
//    
//    NSLog(@"DICTIONARY: %@", diction);
    
    //    int *x = NULL; *x = 42;
}

- (RACSignal *)signal2Backup
{
    NSString *signalName = @"Signal2";
    
    return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        LogInfo(@"Executing %@", signalName);
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            LogError(@"After 1sec delay, sending 1st sendNext");
            
            [subscriber sendNext:signalName];
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                LogError(@"After 1sec delay, sending completed");
                
                [subscriber sendCompleted];
                
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    LogError(@"After 1sec delay, executing implicit doCompletion");
                });
                
            });
            
        });
        
        LogInfo(@"Completed Execution Block: %@", signalName);
        
        return nil;
    }] doNext:^(id x) {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            LogError(@"After 1sec delay, executing explicit doNext with value: %@", x);
        });
    }] doCompleted:^{
        LogInfo(@"About to complete %@", signalName);
    }];
}

@end
