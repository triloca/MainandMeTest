//
//  TwitterManager.h
//  POGO
//
//  Created by Alexander Bukov on 10/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class TwitterManager;

@interface TwitterManager : NSObject

+ (TwitterManager*)sharedInstance;
- (UIViewController*)oAuthTwitterController;
- (BOOL)isAuthorized;
- (void)logout;
- (void)setLoginSuccess:(void(^)(TwitterManager* facebookManager))successBlock
                failure:(void (^)(TwitterManager* facebookManager, NSError* error))failureBlock;

- (void)loadFollowersSuccess:(void(^)(TwitterManager* facebookManager))successBlock
                failure:(void (^)(TwitterManager* facebookManager, NSError* error))failureBlock;
- (NSArray*)followersArray;
- (void)postMessage:(NSString*)idString
            success:(void (^)(TwitterManager *))successBlock
            failure:(void (^)(TwitterManager *, NSError *))failureBlock;

- (void)sendUpdate:(NSString*)text
           success:(void (^)(TwitterManager *))successBlock
           failure:(void (^)(TwitterManager *, NSError *))failureBlock;

+ (void)loadTinyUrlForUrl:(NSString*) url
                  success:(void(^) (NSString* tinyUrl)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception;
@end