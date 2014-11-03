//
//  LoadProductLikesForUserRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadProductLikesForUserRequest.h"

@implementation LoadProductLikesForUserRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"/users/%@/products/likes", self.userId];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.likes = (NSArray *) response;
    }
}

@end
