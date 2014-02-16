//
//  PSSearchResultsViewModel.m
//  PropertySales
//
//  Created by DHANA PRAKASH MUDDINETI on 2/12/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "PSSearchResultsViewModel.h"

@implementation PSSearchResultsViewModel

- (void)setup
{
    ENTRY_LOG;
    
    @weakify(self);
    [RACObserve(self, searchString) subscribeNext:^(NSString *searchString) {
        @strongify(self);
        LogInfo(@"Search String: %@", searchString);
        
        if(searchString == nil || searchString.length <= 0) {
            self.propertiesFromSearchResult = self.properties;
        } else {
            self.propertiesFromSearchResult = [self.properties
                                               filteredArrayUsingPredicate:[[self buildPredicate]
                                                                            predicateWithSubstitutionVariables:@{@"searchString" : searchString}]];
        }
        
        LogInfo(@"After filtering Search results: %lu", [self.propertiesFromSearchResult count]);
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
