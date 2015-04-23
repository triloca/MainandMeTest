//
//  FollowingsRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 05.12.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "FollowingsRequest.h"

@interface FollowingsRequest ()
@property (readonly, nonatomic) NSString *followableTypeString;

@end

@implementation FollowingsRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) followableTypeString {
    switch (_followableType) {
        case FollowableCommunity:
            return @"community";
        case FollowableStore:
            return @"store";
        case FollowableUser:
            return @"user";
    }
    return nil;
}

- (NSString *) path {
    return [NSString stringWithFormat:@"users/%@/follows/followings/%@", self.userId, [self followableTypeString]];
}

- (void) processResponse:(id )response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.followings = (NSArray *) response;
    }
}


@end
