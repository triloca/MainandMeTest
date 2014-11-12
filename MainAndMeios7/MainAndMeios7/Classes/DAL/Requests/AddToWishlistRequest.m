//
//  AddToWishlistRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 12.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AddToWishlistRequest.h"

@implementation AddToWishlistRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"product_lists/%@/list_items", self.wishlistId];
}

- (NSMutableDictionary *) userRequestDictionary {
    NSMutableDictionary *dict = [super userRequestDictionary];
    
    [dict safeSetObject:_productId forKey:@"list_item[product_id]"];
    
    return dict;
}

@end
