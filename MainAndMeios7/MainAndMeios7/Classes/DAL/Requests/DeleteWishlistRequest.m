//
//  DeleteWishlistRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "DeleteWishlistRequest.h"

@implementation DeleteWishlistRequest

- (NSString *) method {
    return @"DELETE";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"/users/%@/product_lists/%@", self.userId, self.productId];
}

@end
