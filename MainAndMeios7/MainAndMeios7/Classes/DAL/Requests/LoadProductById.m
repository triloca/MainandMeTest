//
//  LoadProductById.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadProductById.h"

@implementation LoadProductById

- (id) initWithProductId: (NSNumber *) productId {
    if (self = [super init]) {
        self.productId = productId;
    }
    return self;
}

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"products/%@", [_productId stringValue]];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        self.product = (NSDictionary *) response;
    }
}


@end
