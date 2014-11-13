//
//  SearchRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SearchRequest.h"

@implementation SearchRequest

- (id) initWithSearchType: (SearchType) type searchFilter: (SearchFilter) filter {
    if (self = [super init]) {
        self.page = 1;
        self.searchType = type;
        self.searchFilter = filter;
    }
    return self;
}

//- (NSString *) acceptableContentType {
//    return @"text/html";
//}

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    switch (_searchType) {
        case SearchTypeStores:{
            
            switch (_searchFilter) {
                case SearchFilterNone:
                    return @"/stores";
                    break;
                case SearchFilterPopular:
                    return @"/stores/popular";
                    break;
                case SearchFilterNewly:
                    return @"/stores/latest";
                    break;
                case SearchFilterRandom:
                    return @"/stores/random";
                    break;
                case SearchFilterFututrd:
                    return @"/stores/featured";
                    break;
                case SearchFilterNewlyAll:
                    return @"/stores/latest";
                    break;
                    
                default:
                    break;
            }
            break;
        }
            
        case SearchTypeProducts:{
            switch (_searchFilter) {
                case SearchFilterNone:
                    return @"/products/nearby";
                    break;
                case SearchFilterPopular:
                    return @"/products/popular";
                    break;
                case SearchFilterNewly:
                    return @"/products/latest";
                    break;
                case SearchFilterRandom:
                    return @"/products/random";
                    break;
                case SearchFilterFututrd:
                    return @"/products/featured";
                    break;
                case SearchFilterNewlyAll:
                    return @"/products/nearby";
                    break;
                default:
                    break;
            }
            
            break;
        }
        default:
            break;
    }
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:@(_page) forKey:@"page"];
    [dict safeSetObject:@(kPerPagePropertyValue) forKey:@"per_page"];
    [dict safeSetObject:_searchKey forKey:@"keywords"];
    
    if (_searchFilter != SearchFilterNewlyAll) {
        [dict safeSetObject:@(_coordinate.latitude) forKey:@"lat"];
        [dict safeSetObject:@(_coordinate.longitude) forKey:@"lng"];
        [dict safeSetObject:_city forKey:@"city"];
        [dict safeSetObject:_state forKey:@"state"];
    }
    
    [dict safeSetObject:kRealtimePropertyValue forKey:@"realtime"];

    return dict;
}

- (void) processResponse:(NSArray *)response {
    
   // NSLog(@"Response: %@", response);
    
    if ([response isKindOfClass:[NSArray class]]) {
        self.objects = response;
    }
    
}

@end
