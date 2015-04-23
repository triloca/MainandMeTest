//
//  FollowingsRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 05.12.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"
#import "AuthenticatedRequest.h"
typedef enum EFollowable {
    FollowableStore,
    FollowableUser,
    FollowableCommunity
} Followable;

@interface FollowingsRequest : AuthenticatedRequest

//request
@property (strong, nonatomic) NSString *userId;
@property Followable followableType;


//response
@property (strong, nonatomic) NSArray *followings;
@end
