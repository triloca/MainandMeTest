//
//  AuthenticatedRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AuthenticatedRequest.h"

@implementation AuthenticatedRequest

- (NSMutableDictionary *) userRequestDictionary {
    return [NSMutableDictionary new];
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *requestDict = [self userRequestDictionary];
    [requestDict safeSetObject:self.apiToken forKey:@"_token"];
    return requestDict;
}


@end
