//
//  RegistrationRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 30.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RegistrationRequest.h"

@implementation RegistrationRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return @"users";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:self.email forKey:@"user[email]"];
    [dict safeSetObject:self.username forKey:@"user[name]"];
    [dict safeSetObject:self.password forKey:@"user[password]"];
    [dict safeSetObject:self.password forKey:@"user[password_confirmation]"];
    [dict safeSetObject:@"1" forKey:@"user[terms]"];
    
    return dict;
}


- (void) processResponse:(NSDictionary *)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        self.user = [response safeDictionaryObjectForKey:@"user"];
        self.responseEmail = [[response safeDictionaryObjectForKey:@"user"] safeStringObjectForKey:@"email"];
        self.api_token = [[response safeDictionaryObjectForKey:@"user"] safeStringObjectForKey:@"api_token"];
    }
}

@end
