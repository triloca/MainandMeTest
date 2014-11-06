//
//  RateStoreRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RateStoreRequest.h"

@implementation RateStoreRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"stores/%@/rate", _storeId];
}

- (NSMutableDictionary *) userRequestDictionary {
    NSMutableDictionary *dict = [super userRequestDictionary];
    
    [dict safeSetObject:@(_rate) forKey:@"rate"];
    
    return dict;
}

@end
