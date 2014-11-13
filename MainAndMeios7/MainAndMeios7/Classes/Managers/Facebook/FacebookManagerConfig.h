//
//  FacebookManagerConfig.h
//  AllComponents
//
//  Created by Sasha on 4/19/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//



//! Constants
static NSString * const kFBAppID =                      @"254708664663458";

//! Token cache key
static NSString * const kFBUserDefaultsTokenInfoKey =   @"kFBUserDefaultsTokenInfoKey";

//! Notifications
static NSString* const kFacebookManagerDidLoginNotification =   @"kFacebookManagerDidLoginNotification";
static NSString* const kFacebookManagerDidLogoutNotification =  @"kFacebookManagerDidLogoutNotification";

static NSString *const kFBSessionStateChangedNotification =     @"kFBSessionStateChangedNotifiction";



#if DEBUG && 1
#   define FBLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define FBLog(...)
#endif


