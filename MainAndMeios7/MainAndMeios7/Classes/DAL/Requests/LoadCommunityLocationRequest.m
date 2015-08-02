//
//  LoadCommunityLocationRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadCommunityLocationRequest.h"

@implementation LoadCommunityLocationRequest

- (NSString *) method {
    return @"GET";
}
//http://www.mainandme.com/api/v1/communities?lat=43.0730517&lng=-111
- (NSString *) path {
    return [NSString stringWithFormat:@"/communities?lat=%f&lng=%f", _coordinate.latitude, _coordinate.longitude];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.communities = (NSArray *) response;
    }
}

@end
