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

- (void)clearOldLoginSettings{
    [_userDefaults removeObjectForKey:kUserEmail];
    [_userDefaults removeObjectForKey:kUserPassword];
    [_userDefaults removeObjectForKey:kUserId];
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

- (void)isLastLogin{

}
@end