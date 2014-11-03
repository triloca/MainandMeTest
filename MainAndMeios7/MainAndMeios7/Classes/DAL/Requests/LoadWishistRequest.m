//
//  LoadWishistRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadWishistRequest.h"

@implementation LoadWishistRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"/users/%@/product_lists", self.userId];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) { 
        self.wishlist = (NSArray *) response;
    }
}

@end
