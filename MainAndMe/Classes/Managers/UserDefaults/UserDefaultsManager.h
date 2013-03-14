//
//  UserDefaultsManager.h
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#define kUserEmail              @"kUserEmail"
#define kUserPassword           @"kUserPassword"
#define kUserId                 @"kUserId"
#define kUserAccessToken        @"kUserAccessToken"
#define kUsername               @"kUsername"
#define kUserAuthtoken          @"kUserAuthtoken"


#define kLoginType              @"kLoginType"
#define kLoginTypeStandard      @"kLoginTypeStandard"
#define kLoginTypeViaFacebook   @"kLoginTypeViaFacebook"
#define kLoginTypeViaTwitter    @"kLoginTypeViaTwitter"

#define kReturnedUsername               @"kReturnedUsername"

#define kCachedTwitterAuthData    @"kCachedTwitterAuthData"


@interface UserDefaultsManager : NSObject

+ (UserDefaultsManager*)shared;
- (void)saveStandardLogin:(NSString*)email password:(NSString*)password;
- (void)saveFacebookLogin:(NSString*)userId
                 userName:(NSString*)userName
              accessToken:(NSString*)accessToken
                    email:(NSString*)email;
- (void)saveReturnedUsername:(NSString*)username;
- (NSString*)lastLoginType;
- (NSString*)email;
- (NSString*)password;
- (NSString*)userId;
- (NSString*)accessToken;
- (NSString*)authtoken;
- (NSString*)userName;
- (void)clearOldLoginSettings;

//! Twitter
- (void)saveTwitterAuthData:(NSString*)string forUsername:(NSString *)username;
- (NSString*)twitterAuthDataForUsername:(NSString *)username;
- (void)clearTwitterAuthData;
- (void)saveTwitterLogin:(NSString*)userName
               authToken:(NSString*)authToken
                  userId:(NSString*)userId
                   email:(NSString*)email;
@end