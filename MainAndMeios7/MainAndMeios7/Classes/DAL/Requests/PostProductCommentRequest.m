//
//  PostProductCommentRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PostProductCommentRequest.h"

@implementation PostProductCommentRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"products/%@/comments", _productId];
}

- (NSMutableDictionary *) userRequestDictionary {
    NSMutableDictionary *dict = [super userRequestDictionary];
    [dict safeSetObject:self.comment forKey:@"comment[body]"];
    return dict;
}

@end
