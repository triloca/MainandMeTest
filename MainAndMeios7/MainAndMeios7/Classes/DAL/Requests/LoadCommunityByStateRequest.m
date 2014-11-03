//
//  LoadCommunityByStateRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadCommunityByStateRequest.h"

@implementation LoadCommunityByStateRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return @"search_state_communities";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:_state forKey:@"name"];
    
    return dict;
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.communities = (NSArray *) response;
    }
}


@end
