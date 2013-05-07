//
//  NotificationManager.h
//  MainAndMe
//
//  Created by Sasha on 4/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface NotificationManager : NSObject
@property (strong, nonatomic) NSString* deviceToken;


+ (NotificationManager*)shared;
+ (void)loadNotificationsWithSuccess:(void(^) (NSArray* notif)) success
                             failure:(void(^) (NSError* error, NSString* errorString)) failure
                           exception:(void(^) (NSString* exceptionString))exception;

+ (void)addDeviceToken:(NSString*)token
               success:(void(^) (NSArray* obj)) success
               failure:(void(^) (NSError* error, NSString* errorString)) failure
             exception:(void(^) (NSString* exceptionString))exception;

+ (void)removeNotifications:(NSNumber*)number
                    success:(void(^) (id obj)) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception;

- (BOOL)isContainId:(NSNumber*)number;
- (NSNumber*)notificationIdByObjectId:(NSNumber*)number;
@end