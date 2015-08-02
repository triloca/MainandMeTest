//
//  LoadStore.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadStoreRequest.h"

@implementation LoadStoreRequest

- (id) initWithStoreId: (NSNumber *) storeId {
    if (self = [super init]) {
        self.storeId = storeId;
    }
    return self;
}

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"stores/%@?_token=%@", self.storeId, [CommonManager shared].apiToken];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSDictionary class]]) { 
        self.storeDetails = (NSDictionary *) response;
    }
}

@end
