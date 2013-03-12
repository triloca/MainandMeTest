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

@interface UserDefaultsManager : NSObject

+ (UserDefaultsManager*)shared;
- (void)saveStandardLogin:(NSString*)email password:(NSString*)password;
- (void)saveReturnedUsername:(NSString*)username;
- (NSString*)lastLoginType;
- (NSString*)email;
- (NSString*)password;
@end