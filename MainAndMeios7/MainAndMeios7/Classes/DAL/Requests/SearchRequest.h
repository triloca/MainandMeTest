//
//  SearchRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"
#import <CoreLocation/CoreLocation.h>

#define kRealtimePropertyValue @"true"
#define kPerPagePropertyValue 30

typedef enum {
    SearchTypeStores = 0,
    SearchTypeProducts
} SearchType;

typedef enum {
    SearchFilterPopular = 0,
    SearchFilterNewly,
    SearchFilterRandom,
    SearchFilterFututrd,
    SearchFilterNone,
    SearchFilterNewlyAll,
} SearchFilter;

@interface SearchRequest : ServiceRequest

//request
@property (assign, nonatomic) SearchType searchType;
@property (assign, nonatomic) SearchFilter searchFilter;
@property CLLocationCoordinate2D coordinate;
@property NSString *city;
@property NSString *state;
@property NSUInteger page;
@property (strong, nonatomic) NSString* searchKey;

//response
@property (strong, nonatomic) NSArray *objects;

- (id) initWithSearchType: (SearchType) type searchFilter: (SearchFilter) filter;

@end
