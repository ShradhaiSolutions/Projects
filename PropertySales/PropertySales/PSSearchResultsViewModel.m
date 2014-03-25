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

    @weakify(self);
    [[RACSignal
     combineLatest:@[RACObserve(self, searchString), RACObserve(self, selectedSaleDatesForFiltering)]
     reduce:^id(NSString *searchString, NSSet *selectedSaleDatesForFiltering){
         @strongify(self);
         LogInfo(@"Search String: %@, SelectedSaleDates: %@", searchString, selectedSaleDatesForFiltering);
         
         if(searchString == nil) {
             searchString = @"";
         }
         
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
            "OR (plaintiff CONTAINS[c] $searchString)"
            "OR (name CONTAINS[c] $searchString)"
            "OR (address CONTAINS[c] $searchString)"
            "OR (attyName CONTAINS[c] $searchString)"
            "OR (appraisal CONTAINS[c] $searchString)"
            "OR (minBid CONTAINS[c] $searchString)"
            "OR (township CONTAINS[c] $searchString)"
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
