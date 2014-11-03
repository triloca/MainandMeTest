//
//  LoadCommunityRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadCommunityRequest.h"

@implementation LoadCommunityRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"communities/%@", _communityId];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        self.community = (NSDictionary *) response;
    }
}

@end
