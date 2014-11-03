//
//  LoadNearbyProducts.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadNearbyProductsRequest.h"

@implementation LoadNearbyProductsRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return @"products";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict safeSetObject:@(_coordinate.latitude) forKey:@"lat"];
    [dict safeSetObject:@(_coordinate.longitude) forKey:@"lng"];
    
    return dict;
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.products = (NSArray *) response;
    }
}

@end
