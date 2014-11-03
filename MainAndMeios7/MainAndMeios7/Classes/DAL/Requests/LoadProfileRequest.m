//
//  LoadProfile.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadProfileRequest.h"

@implementation LoadProfileRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"/users/%@", self.userId];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSDictionary class]]) { 
        self.profile = (NSDictionary *) response;
    }
}

@end
