//
//  SaveCurrentUserRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SaveCurrentUserRequest.h"

@implementation SaveCurrentUserRequest

- (NSString *) method {
    return @"PUT";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"users/%@", _userId];
}

- (NSMutableDictionary *) userRequestDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    [dictionary safeSetObject:_userId forKey:@"id"];
    [dictionary safeSetObject:_username forKey:@"user[name]"];
    [dictionary safeSetObject:_password forKey:@"user[password]"];
    [dictionary safeSetObject:_password forKey:@"user[password_confirmation]"];
    [dictionary safeSetObject:_birthday forKey:@"user[date_of_birth]"];
    [dictionary safeSetObject:_address forKey:@"user[address]"];
    [dictionary safeSetObject:_phoneNumber forKey:@"user[phone_number]"];
    [dictionary safeSetObject:@(_emailCommunities) forKey:@"user[setting_attributes][email_communities]"];
    [dictionary safeSetObject:@(_emailStores) forKey:@"user[setting_attributes][email_stores]"];
    [dictionary safeSetObject:@(_emailPeople) forKey:@"user[setting_attributes][email_people]"];
    [dictionary safeSetObject:@(_wishlist) forKey:@"user[setting_attributes][wishlist]"];

    return dictionary;
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        self.user = (NSDictionary *) response;
    }
}

@end
