//
//  LoadStore.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadStoreRequest.h"

@implementation LoadStoreRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"stores/%@", self.storeId];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSDictionary class]]) { 
        self.storeDetails = (NSDictionary *) response;
    }
}

@end
