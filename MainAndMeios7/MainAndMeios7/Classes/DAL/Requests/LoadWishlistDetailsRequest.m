    //
//  LoadWishlistDetailsRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.12.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadWishlistDetailsRequest.h"

@implementation LoadWishlistDetailsRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"/product_lists/%@/list_items", self.wishlistId];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.wishlist = (NSArray *) response;
    }
}


@end
