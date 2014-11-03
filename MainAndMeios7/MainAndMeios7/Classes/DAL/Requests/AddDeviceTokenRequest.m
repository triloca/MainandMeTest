//
//  AddDeviceTokenRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AddDeviceTokenRequest.h"

@implementation AddDeviceTokenRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return @"devices";
}

- (NSMutableDictionary *) userRequestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:self.deviceToken forKey:@"device[token]"];
    return dict;
}


@end
