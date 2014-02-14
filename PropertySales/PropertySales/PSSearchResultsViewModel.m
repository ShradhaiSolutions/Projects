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
    
    [RACObserve(self, searchString) subscribeNext:^(NSString *searchStr) {
        NSLog(@"Search String: %@", searchStr);
        
        if(searchStr == nil || searchStr.length <= 0) {
            self.propertiesFromSearchResult = self.properties;
        } else {
            self.propertiesFromSearchResult = [self.properties
                                               filteredArrayUsingPredicate:[NSPredicate
                                                                            predicateWithFormat:@"(township CONTAINS %@)", searchStr]];
        }
        
        LogInfo(@"After filtering Search results: %d", [self.propertiesFromSearchResult count]);
    }];
    
    EXIT_LOG;
}

@end
