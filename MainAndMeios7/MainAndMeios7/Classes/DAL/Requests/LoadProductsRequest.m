//
//  LoadProductsByKeywordsRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadProductsRequest.h"


#define kPerPagePropertyValue 30

@implementation LoadProductsRequest

//self.perPage = kPerPagePropertyValue;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.perPage = kPerPagePropertyValue;
    }
    return self;
}

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return @"products";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict safeSetObject:_communityId forKey:@"community_id"];
    [dict safeSetObject:_keywords forKey:@"keywords"];
    [dict safeSetObject:@(_perPage) forKey:@"per_page"];
    
    return dict;
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.products = (NSArray *) response;
    }
}

@end
