//
//  LikeStoreRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LikeStoreRequest.h"

@implementation LikeStoreRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"stores/%@/likes", _storeId];
}

@end
