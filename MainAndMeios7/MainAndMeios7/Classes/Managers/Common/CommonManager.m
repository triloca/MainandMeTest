//
//  CommonManager.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/1/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "CommonManager.h"
#import "FacebookManager.h"
#import "TwitterManager.h"

#define k_USER_ID           @"k_USER_ID"
#define k_API_TOKEN         @"k_API_TOKEN"


@interface CommonManager()

@end


@implementation CommonManager
#pragma mark _______________________ Class Methods _________________________

#pragma mark - Shared Instance and Init
+ (CommonManager *)shared {
    
    static CommonManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

#pragma mark ____________________________ Init _____________________________

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
    }
    return self;
}

#pragma mark _______________________ Privat Methods ________________________



#pragma mark _______________________ Delegates _____________________________



#pragma mark _______________________ Public Methods ________________________

#pragma mark User ID
- (NSString*)userId{
   return [[NSUserDefaults standardUserDefaults] stringForKey:k_USER_ID];
}

- (void)setupUserId:(NSString*)userId{
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:k_USER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark API token
- (NSString*)apiToken{
    return [[NSUserDefaults standardUserDefaults] stringForKey:k_API_TOKEN];
}

- (void)setupApiToken:(NSString*)apiToken{
    [[NSUserDefaults standardUserDefaults] setValue:apiToken forKey:k_API_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark email
- (NSString*)email{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"emailKey"];
}

- (void)setupEmail:(NSString*)email{
    [[NSUserDefaults standardUserDefaults] setValue:email forKey:@"emailKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark pass
- (NSString*)pass{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"passKey"];
}

- (void)setupPass:(NSString*)pass{
    [[NSUserDefaults standardUserDefaults] setValue:pass forKey:@"passKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark userName
- (NSString*)userName{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"userNameKey"];
}

- (void)setupUserName:(NSString*)userName{
    [[NSUserDefaults standardUserDefaults] setValue:userName forKey:@"userNameKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark fbID
- (NSString*)fbID{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"fbIDKey"];
}

- (void)setupFbID:(NSString*)fbID{
    [[NSUserDefaults standardUserDefaults] setValue:fbID forKey:@"fbIDKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark authenticatedID
- (NSString*)authenticatedID{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"authenticatedIDKey"];
}

- (void)setupAuthenticatedID:(NSString*)authenticatedID{
    [[NSUserDefaults standardUserDefaults] setValue:authenticatedID forKey:@"authenticatedIDKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark credentialToken
- (NSString*)credentialToken{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"credentialTokenKey"];
}

- (void)setupCredentialToken:(NSString*)credentialToken{
    [[NSUserDefaults standardUserDefaults] setValue:credentialToken forKey:@"credentialTokenKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark last login
- (LoginMethod)loginMethod{
    LoginMethod lm = (LoginMethod)[[NSUserDefaults standardUserDefaults] integerForKey:@"loginMethodKey"];
    loginMethod = lm;
    return lm;
}

- (void)setLoginMethod:(LoginMethod)_loginMethod{
    loginMethod = _loginMethod;
    [[NSUserDefaults standardUserDefaults] setInteger:loginMethod forKey:@"loginMethodKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}




- (BOOL)isLoggedIn{
    
    if ([self apiToken].length > 0 && [self userId].length > 0) {
        return YES;
    }else{
        return NO;
    }
}



#pragma mark Logout
- (void)logout{
    [self setupApiToken:nil];
    [self setupUserId:nil];
    
    [[FacebookManager shared] logOut];
    [[TwitterManager shared] logout];
    
    self.loginMethod = LoginMethodNone;
    [self setupEmail:@""];
    [self setupPass:@""];
    [self setupCredentialToken:@""];
    [self setupAuthenticatedID:@""];
    [self setupFbID:@""];
    [self setupUserName:@""];
    
}

#pragma mark _______________________ Notifications _________________________



@end
