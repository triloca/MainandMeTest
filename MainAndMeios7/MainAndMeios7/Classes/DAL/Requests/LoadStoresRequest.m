//
//  LoadAllStoresRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadStoresRequest.h"

@implementation LoadStoresRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return @"stores";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict safeSetObject:_communityId forKey:@"community_id"];
    [dict safeSetObject:_keywords forKey:@"keywords"];
    
    return dict;
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.stores = (NSArray *) response;
    }
}


@end
