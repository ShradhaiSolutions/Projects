//
//  PSTestViewController.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/1/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSTestViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "PSDataController.h"
#import "PSLocationManager.h"
#import "PSProperty+LocationParser.h"

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
	// Do any additional setup after loading the view.
    
//    PSDataController *dataController = [[PSDataController alloc] init];
//    [dataController fetchData];
    
//    PSLocationManager *locationManager = [[PSLocationManager alloc] init];
//    locationManager.propertiesArray = [dataController getProperties];
//    LogDebug(@"Properties Array: %@", locationManager.propertiesArray);
//    [locationManager getCoordinates];
    
//    __block PSProperty *property = [[PSProperty alloc] init];
//    property.address = @"2540 HIGHWOOD LN";
//    property.township = @"COLERAIN TWSP";
//
//    LogDebug(@"Address: %@", [property getAddress]);
//    
//    [[property convertAddressToCoordinate] subscribeError:^(NSError *error) {
//        LogError(@"Error Happened");
//    } completed:^{
//        LogInfo(@"Latitude = %f, Longitude = %f", property.coordinates.latitude, property.coordinates.longitude);
//    }];

//    [self testMultipleProperties];
//    [self testPropertyParsing];

    PSDataController *dataController = [[PSDataController alloc] init];
    NSDictionary *locationCoordinatesMap = [dataController getLocationCoordinatesMap];
    
    for (NSString *key in locationCoordinatesMap) {
        NSDictionary *coordinateDictionary = [locationCoordinatesMap objectForKey:key];
        
//        LogDebug(@"Address: %@ Coordinates: %@", key, [NSValue valueWithMKCoordinate:[self dictionaryToCoordinate:coordinateDictionary]]);
        LogDebug(@"Address: %@ Coordinates: {%@, %@}", key, coordinateDictionary[@"lat"], coordinateDictionary[@"long"]);
    }
}

- (void)testPropertyParsing
{
    ENTRY_LOG;
    
    PSLocationManager *locationManager = [[PSLocationManager alloc] init];

    PSDataController *dataController = [[PSDataController alloc] init];
    locationManager.propertiesArray = [dataController getProperties];
//    LogDebug(@"Properties Array: %@", locationManager.propertiesArray);
    
    __block NSArray *propertiesModel = [locationManager createPropertiesModel];
    LogInfo(@"Total number of properties: %u", [propertiesModel count]);
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

- (void)saveLocationMapping:(NSArray *)propertiesModel
{
    ENTRY_LOG;
    
    NSMutableDictionary *locationCoordinatesMap = [NSMutableDictionary dictionary];
    
    for (PSProperty *property in propertiesModel) {
        if([property getAddress] != nil && CLLocationCoordinate2DIsValid(property.coordinates)) {
            [locationCoordinatesMap setObject:[self coordinateToDictionary:property.coordinates]
                                       forKey:[property getAddress]];
        }
    }
    
    LogInfo(@"Location Coordinates Map: %@", locationCoordinatesMap);
    
    PSDataController *dataController = [[PSDataController alloc] init];
    [dataController saveLocationsMap:locationCoordinatesMap];
    
    EXIT_LOG;
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
        int numberOfLocationsInError = [self printSummary:propertiesModel];
        [self saveLocationMapping:propertiesModel];
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
    
    NSString *string = nil;
    
    NSDictionary *diction = @{@"key":@"value",
                              @"key1":string};
    
    NSLog(@"DICTIONARY: %@", diction);
    
    //    int *x = NULL; *x = 42;
}

@end
