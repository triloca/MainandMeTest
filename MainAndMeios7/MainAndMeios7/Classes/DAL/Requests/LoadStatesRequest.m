//
//  LoadStatesRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadStatesRequest.h"

@implementation LoadStatesRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return @"/states";
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        self.states = (NSDictionary *) response;
    }
}
@end
