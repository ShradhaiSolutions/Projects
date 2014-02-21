//
//  PSSearchResultsViewModel.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/12/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSSearchResultsViewModel.h"

@implementation PSSearchResultsViewModel

- (id)init
{
    self = [super init];
    if (self) {
        _selectedSaleDatesForFiltering = [NSSet set];
    }
    return self;
}

- (void)setup
{
    ENTRY_LOG;

    RAC(self, propertiesFromSearchResult) = [RACObserve(self, properties) deliverOn:[RACScheduler mainThreadScheduler]];
    
    
//    [[RACObserve(self, properties)
//      deliverOn:[RACScheduler mainThreadScheduler]]
//     subscribeNext:^(id x) {
//         LogError(@"ViewModel - data into search result array. isMainThread: %@. First Property: %@", [NSThread isMainThread] ? @"YES" : @"NO", x[0]);
//         self.propertiesFromSearchResult = x;
//    }];
    
//    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
//    [dateFormmater setDateFormat:@"MM/dd/yyyy"];
//    
//    self.selectedSaleDatesForFiltering = [NSSet setWithArray:@[[dateFormmater dateFromString:@"02/20/2014"],
//                                                               [dateFormmater dateFromString:@"02/27/2014"]]];
    
    @weakify(self);
    [[RACSignal
     combineLatest:@[RACObserve(self, searchString), RACObserve(self, selectedSaleDatesForFiltering)]
     reduce:^id(NSString *searchString, NSSet *selectedSaleDatesForFiltering){
         @strongify(self);
         LogInfo(@"Search String: %@, SelectedSaleDates: %@", searchString, selectedSaleDatesForFiltering);
         
         if(searchString.length > 0 || [selectedSaleDatesForFiltering count] > 0) {
             self.propertiesFromSearchResult = [self.properties
                                                filteredArrayUsingPredicate:[[self buildPredicate]
                                                                             predicateWithSubstitutionVariables:@{@"searchString" : searchString, @"searchDates" : selectedSaleDatesForFiltering}]];
         } else {
             self.propertiesFromSearchResult = self.properties;
         }
         
         LogInfo(@"After filtering Search results: %lu", [self.propertiesFromSearchResult count]);
         
         return nil;
         
     }] subscribeCompleted:^{
         LogInfo(@"Done Filtering...");
     }];
    
    EXIT_LOG;
}

- (NSPredicate *)buildPredicate
{
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(caseNo CONTAINS[cd] $searchString)"
            "OR (plaintiff CONTAINS[cd] $searchString)"
            "OR (name CONTAINS[cd] $searchString)"
            "OR (address CONTAINS[cd] $searchString)"
            "OR (attyName CONTAINS[cd] $searchString)"
            "OR (appraisal CONTAINS[cd] $searchString)"
            "OR (minBid CONTAINS[cd] $searchString)"
            "OR (township CONTAINS[cd] $searchString)"
            "OR (saleData IN $searchDates)"
     ];
    
    return searchPredicate;
}

- (NSArray *)propertiesFromSearchResult
{
    if(_propertiesFromSearchResult == nil) {
        return self.properties;
    } else {
        return _propertiesFromSearchResult;
    }
}

@end
