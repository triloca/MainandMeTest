//
//  LoadStoresForCategory.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadStoresForCategory.h"

@implementation LoadStoresForCategory

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"categories/%@/stores", _categoryId];
}

- (NSDictionary *) requestDictionary {
    if (self.communityId)
        return @{@"community_id": _communityId};
    return @{};
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.stores = (NSArray *) response;
    }
}

@end
