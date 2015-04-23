//
//  LoadProfile.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "EditProfileRequest.h"

@implementation EditProfileRequest

- (NSString *) method {
    return @"PUT";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"/users/%@", self.userId];
}


- (NSMutableDictionary *) userRequestDictionary {
    
     NSMutableDictionary *dict = [super userRequestDictionary];
    
    if (_name.length > 0) {
        [dict safeSetObject:self.name forKey:@"user[name]"];
    }
    if (_phone.length > 0) {
        [dict safeSetObject:self.phone forKey:@"user[phone_number]"];
    }
    if (_address.length > 0) {
        [dict safeSetObject:self.address forKey:@"user[address]"];
    }
    if (_password.length > 0) {
        [dict safeSetObject:self.password forKey:@"user[password]"];
    }
    if (_confirmPassword.length > 0) {
        [dict safeSetObject:self.confirmPassword forKey:@"user[password_confirmation]"];
    }
    
    return dict;
}


- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSDictionary class]]) { 
        self.profile = (NSDictionary *) response;
    }
}

@end
