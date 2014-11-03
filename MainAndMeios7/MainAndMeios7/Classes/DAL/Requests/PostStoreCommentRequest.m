//
//  PostStoreCommentRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PostStoreCommentRequest.h"

@implementation PostStoreCommentRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"stores/%@/comments", _storeId];
}

- (NSMutableDictionary *) userRequestDictionary {
    NSMutableDictionary *dict = [super userRequestDictionary];
    [dict safeSetObject:self.comment forKey:@"comment[body]"];
    return dict;
}


@end


