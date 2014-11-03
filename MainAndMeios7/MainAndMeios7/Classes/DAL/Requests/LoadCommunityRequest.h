//
//  LoadCommunityRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadCommunityRequest : ServiceRequest

//request
@property (strong, nonatomic) NSNumber *communityId;

//response
@property (strong, nonatomic) NSDictionary *community;

@end
