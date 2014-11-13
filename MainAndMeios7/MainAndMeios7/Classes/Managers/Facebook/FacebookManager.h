//
//  FacebookManager.h
//  AllComponents
//
//  Created by Sasha on 4/5/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//

//#import <FacebookSDK/FBGraphUser.h>
#import <FacebookSDK/FacebookSDK.h>

#import "FacebookManagerConfig.h"

@class FBRequestConnection, FBSession;

#ifndef FB_SESSIONSTATEOPENBIT
typedef int FBSessionState;
#endif
@interface FacebookManager : NSObject

@property (strong, nonatomic) id/*<FBGraphUser>*/ user;
@property (strong, nonatomic) UIImage* avatarImage;
@property (strong, nonatomic) NSMutableArray* friends;

+ (FacebookManager*)shared;

- (void)loginWithReadPermissions:(NSArray*)permissions
                    allowLoginUI:(BOOL)allowLoginUI
                         success:(void (^)(FBSession *session, FBSessionState status))success
                         failure:(void (^)(FBSession *session, FBSessionState status, NSError *error))failure
                   olreadyLogged:(void (^)(FBSession *session, FBSessionState status))olreadyLogged;

- (void)login;

- (void)logOut;

- (void)loadMeWithSuccess:(void(^)(id/*<FBGraphUser>*/ user))success
                  failure:(void(^)(FBRequestConnection *connection, id result, NSError *error))failure;

- (void)loadFriendsWithSuccess:(void(^)(NSArray* friends))success
                       failure:(void(^)(FBRequestConnection *connection, id result, NSError *error))failure;

- (void)loadFriendsForUser:(NSString*)userID
                 pagingURL:(NSString*)paginURL
                   success:(void(^)(NSArray* friends, NSString* nextPage, NSString* prevPage))success
                   failure:(void(^)(FBRequestConnection *connection, id result, NSError *error))failure;

- (NSString*)userAvatarURL:(NSString*)userID type:(NSString*)type; //! type=large

- (void)avatarImageForUser:(NSString*)fbID
                   success:(void (^)(UIImage* image))success
                   failure:(void (^)(NSError* error))failure;



#pragma mark - Post
- (void)postToFriend:(NSString*)fID
                name:(NSString*)name
               title:(NSString*)title
         description:(NSString*)description
                link:(NSString*)link
         pictureLink:(NSString*)pictureLink
             success:(void(^)(FBRequestConnection *connection, id result, NSError *error))success
             failure:(void(^)(FBRequestConnection *connection, id result, NSError *error))failure;

//!
- (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication;

@end