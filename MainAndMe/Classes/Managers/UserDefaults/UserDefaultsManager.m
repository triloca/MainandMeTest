//
//  UserDefaultsManager.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "UserDefaultsManager.h"


@interface UserDefaultsManager()
@property (strong, nonatomic) NSUserDefaults* userDefaults;
@end


@implementation UserDefaultsManager

#pragma mark - Shared Instance and Init
+ (UserDefaultsManager *)shared {
    
    static UserDefaultsManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

#pragma mark - Save Login type

- (void)saveStandardLogin:(NSString*)email password:(NSString*)password{
    [self clearOldLoginSettings];
    [_userDefaults setObject:kLoginTypeStandard forKey:kLoginType];
    [_userDefaults setObject:email forKey:kUserEmail];
    [_userDefaults setObject:password forKey:kUserPassword];
    [_userDefaults synchronize];
}

- (void)saveFacebookLogin:(NSString*)userId
                 userName:(NSString*)userName
              accessToken:(NSString*)accessToken
                    email:(NSString*)email{
    
    [self clearOldLoginSettings];
    [_userDefaults setObject:kLoginTypeViaFacebook forKey:kLoginType];
    [_userDefaults setObject:email forKey:kUserEmail];
    [_userDefaults setObject:userId forKey:kUserId];
    [_userDefaults setObject:userName forKey:kUsername];
    [_userDefaults setObject:accessToken forKey:kUserAccessToken];
    [_userDefaults synchronize];
}


- (void)clearOldLoginSettings{
    [_userDefaults removeObjectForKey:kUserEmail];
    [_userDefaults removeObjectForKey:kUserPassword];
    [_userDefaults removeObjectForKey:kUserId];
    [_userDefaults removeObjectForKey:kUsername];
    [_userDefaults removeObjectForKey:kUserAccessToken];
    [_userDefaults removeObjectForKey:kUserAuthtoken];
    [_userDefaults removeObjectForKey:kLoginType];
    
    [_userDefaults removeObjectForKey:kReturnedUsername];
    [_userDefaults synchronize];
}

- (void)saveReturnedUsername:(NSString*)username{
    [_userDefaults setObject:username forKey:kReturnedUsername];
    [_userDefaults synchronize];
}

#pragma mark - Twitter
- (void)saveTwitterAuthData:(NSString*)string forUsername:(NSString *)username{
    [_userDefaults setObject:string forKey:kCachedTwitterAuthData];
    [_userDefaults synchronize];
    
}

- (NSString*)twitterAuthDataForUsername:(NSString *)username{
    return [_userDefaults objectForKey:kCachedTwitterAuthData];
}

- (void)clearTwitterAuthData{
    [_userDefaults removeObjectForKey:kCachedTwitterAuthData];
    [_userDefaults synchronize];
}

- (void)saveTwitterLogin:(NSString*)userName
               authToken:(NSString*)authToken
                  userId:(NSString*)userId
                  email:(NSString*)email{
    
    [self clearOldLoginSettings];
    [_userDefaults setObject:kLoginTypeViaTwitter forKey:kLoginType];
    [_userDefaults setObject:userId forKey:kUserId];
    [_userDefaults setObject:userName forKey:kUsername];
    [_userDefaults setObject:authToken forKey:kUserAuthtoken];
    [_userDefaults setObject:email forKey:kUserEmail];
    [_userDefaults synchronize];
}



#pragma mark - 
- (NSString*)lastLoginType{
    return [_userDefaults objectForKey:kLoginType];
}

- (NSString*)email{
    return [_userDefaults objectForKey:kUserEmail];
}

- (NSString*)userId{
    return [_userDefaults objectForKey:kUserId];
}

- (NSString*)userName{
    return [_userDefaults objectForKey:kUsername];
}


- (NSString*)accessToken{
    return [_userDefaults objectForKey:kUserAccessToken];
}

- (NSString*)authtoken{
    return [_userDefaults objectForKey:kUserAuthtoken];
}

- (NSString*)password{
    return [_userDefaults objectForKey:kUserPassword];
}

@end