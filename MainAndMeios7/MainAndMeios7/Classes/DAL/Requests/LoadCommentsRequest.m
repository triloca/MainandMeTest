//
//  LoadCommentsRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadCommentsRequest.h"

@implementation LoadCommentsRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"/products/%@/comments", self.userId];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.comments = (NSArray *) response;
    }
}

@end
