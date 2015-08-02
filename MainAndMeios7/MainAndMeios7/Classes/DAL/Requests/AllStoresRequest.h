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


@interface AllStoresRequest : ServiceRequest

//request
@property (strong, nonatomic) CLLocation* location;
@property NSUInteger page;
@property NSUInteger perPage;

@property (strong, nonatomic) NSString* community_id;

//response
@property (strong, nonatomic) NSArray *objects;

- (id) initWithCommunity:(NSString*)community_id;

@end
