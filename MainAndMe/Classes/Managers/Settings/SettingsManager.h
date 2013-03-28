//
//  SettingsManager.h
//  MainAndMe
//
//  Created by Sasha on 3/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface SettingsManager : NSObject

+ (SettingsManager*)shared;

//! Load Current User
+ (void)loadCurrentUserWithSuccess:(void(^) (NSDictionary* profile)) success
                           failure:(void(^) (NSError* error, NSString* errorString)) failure
                         exception:(void(^) (NSString* exceptionString))exception;

//! Update Current User
+ (void)saveCurrentUserWithName:(NSString*)username
                       password:(NSString*)password
                       birthday:(NSString*)birthday
                        address:(NSString*)address
                   phone_number:(NSString*)phone_number
              email_communities:(BOOL)email_communities
                   email_stores:(BOOL)email_stores
                   email_people:(BOOL)email_people
                       wishlist:(BOOL)wishlist
                        success:(void(^) (NSDictionary* profile)) success
                        failure:(void(^) (NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* exceptionString))exception;
@end