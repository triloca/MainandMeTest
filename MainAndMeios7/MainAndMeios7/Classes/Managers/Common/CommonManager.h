//
//  CommonManager.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/1/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#define kAppColorGreen [UIColor colorWithRed:42/255.f green:189/255.f blue:121/255.f alpha:1]
#define kAppColorYellow [UIColor colorWithRed:255/255.f green:251/255.f blue:155/255.f alpha:1]

typedef enum {
    LoginMethodNone = 0,
    LoginMethodEmail,
    LoginMethodFB,
    LoginMethodTwitter
} LoginMethod;

@interface CommonManager : NSObject{

    LoginMethod loginMethod;
}

+ (CommonManager*)shared;

#pragma mark User ID
- (NSString*)userId;
- (void)setupUserId:(NSString*)userId;

#pragma mark API token
- (NSString*)apiToken;
- (void)setupApiToken:(NSString*)apiToken;

#pragma mark Is logged
- (BOOL)isLoggedIn;

#pragma mark Logout
- (void)logout;

#pragma mark email
- (NSString*)email;
- (void)setupEmail:(NSString*)email;

#pragma mark pass
- (NSString*)pass;
- (void)setupPass:(NSString*)pass;

#pragma mark userName
- (NSString*)userName;
- (void)setupUserName:(NSString*)userName;

#pragma mark authenticatedID
- (NSString*)authenticatedID;
- (void)setupAuthenticatedID:(NSString*)authenticatedID;

#pragma mark credentialToken
- (NSString*)credentialToken;
- (void)setupCredentialToken:(NSString*)credentialToken;

#pragma mark fbID
- (NSString*)fbID;
- (void)setupFbID:(NSString*)fbID;


#pragma mark last login
- (LoginMethod)loginMethod;
- (void)setLoginMethod:(LoginMethod)loginMethod;

@end