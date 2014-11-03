//
//  ForgotPasswordRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ForgotPasswordRequest.h"

@implementation ForgotPasswordRequest


- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return @"users/send_reset_password_token";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:self.email forKey:@"[email]"];
    
    return dict;
}

@end
