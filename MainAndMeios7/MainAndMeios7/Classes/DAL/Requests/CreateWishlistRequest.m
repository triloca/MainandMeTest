//
//  CreateWishlistRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "CreateWishlistRequest.h"

@implementation CreateWishlistRequest


- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"users/%@/product_lists", _userId];
}

- (NSMutableDictionary *) userRequestDictionary {
    NSMutableDictionary *dict = [super userRequestDictionary];
    
    [dict safeSetObject:_name forKey:@"product_list[name]"];
    
    return dict;
}

@end
