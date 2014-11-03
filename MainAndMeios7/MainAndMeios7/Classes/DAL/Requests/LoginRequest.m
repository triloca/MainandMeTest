//
//  LoginRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 30.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoginRequest.h"

@implementation LoginRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return @"users/sign_in";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:self.email forKey:@"[user_login][email]"];
    [dict safeSetObject:self.password forKey:@"[user_login][password]"];
    
    return dict;
}

- (void) processResponse:(NSObject *)response {
    NSDictionary *responseDict = (NSDictionary *) response;
    
    self.user = [responseDict safeDictionaryObjectForKey:@"user"];
    self.apiToken = [_user safeStringObjectForKey:@"api_token"];

}

@end
