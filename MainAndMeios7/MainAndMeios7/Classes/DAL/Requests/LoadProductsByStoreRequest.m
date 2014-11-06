//
//  LoadProductsRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadProductsByStoreRequest.h"

@implementation LoadProductsByStoreRequest

//- (NSString *) acceptableContentType {
//    return @"text/html";
//}

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return (_latest ? [NSString stringWithFormat:@"/stores/%@/products/latest", self.storeId] : [NSString stringWithFormat:@"/stores/%@/products", self.storeId]);
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) { 
        self.products = (NSArray *) response;
    }
}
@end
