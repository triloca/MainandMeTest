//
//  LoginSignUpManager.h
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface LoginSignUpManager : NSObject

+ (LoginSignUpManager*)shared;

+ (void)signUpWithEmail:(NSString*)email
               password:(NSString*)password
               userName:(NSString*)userName
                success:(void(^) (NSString* token, NSString* email)) success
                failure:(void(^) (NSError* error, NSString* errorString)) failure
              exception:(void(^) (NSString* exceptionString))exception;

//! Login request
-(void)loginWithEmail:(NSString*)email
             password:(NSString*)password
              success:(void(^) (NSDictionary* user)) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception;

//! Logout
- (void)logout;

@end