//
//  LoadCommunityLocationRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadCommunityLocationRequest : ServiceRequest

//request
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

//response
@property (strong, nonatomic) NSArray *communities;

@end
