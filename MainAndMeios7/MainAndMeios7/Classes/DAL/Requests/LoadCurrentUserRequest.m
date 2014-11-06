//
//  LoadCurrentUser.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadCurrentUserRequest.h"

@implementation LoadCurrentUserRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return @"users/current";
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        self.user = (NSDictionary *) response;
    }
}

@end
