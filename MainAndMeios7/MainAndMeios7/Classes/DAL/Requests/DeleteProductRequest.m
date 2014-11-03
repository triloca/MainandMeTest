//
//  DeleteProductRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "DeleteProductRequest.h"

@implementation DeleteProductRequest

- (NSString *) method {
    return @"DELETE";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"product_lists/%@/list_items/%@", self.wishlistId, self.productId];
}

@end
