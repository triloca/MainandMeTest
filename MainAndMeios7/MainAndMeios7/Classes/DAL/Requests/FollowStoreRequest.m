//
//  FollowStoreRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "FollowStoreRequest.h"

@implementation FollowStoreRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"follow/store/%@", _storeId];
}

@end
