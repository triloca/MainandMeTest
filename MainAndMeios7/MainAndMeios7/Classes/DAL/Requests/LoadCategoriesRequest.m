//
//  LoadCategoriesRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadCategoriesRequest.h"

@implementation LoadCategoriesRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return @"categories";
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.categories = (NSArray *) response;
    }
}

@end
