//
//  LoginViaSocialRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoginViaSocialRequest.h"

@implementation LoginViaSocialRequest

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return @"authenticae/create";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:self.userId forKey:@"omniauth[uid]"];
    [dict safeSetObject:self.type forKey:@"omniauth[provider]"];
    [dict safeSetObject:self.credentialToken forKey:@"omniauth[credentials][token]"];
    [dict safeSetObject:@"" forKey:@"omniauth[credentials][secret]"];
    [dict safeSetObject:self.email forKey:@"omniauth[info][email]"];
    [dict safeSetObject:self.username forKey:@"omniauth[info][name]"];
    [dict safeSetObject:@"" forKey:@"omniauth[info][image]"];
    [dict safeSetObject:@"1" forKey:@"omniauth[info][terms]"];
    
    return dict;
}

- (void) processResponse:(NSObject *)response {
    NSDictionary *responseDict = (NSDictionary *) response;
    
    self.user = [responseDict safeDictionaryObjectForKey:@"user"];
    self.apiToken = [_user safeStringObjectForKey:@"api_token"];
    
}

@end
