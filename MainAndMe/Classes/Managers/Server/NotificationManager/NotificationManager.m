//
//  NotificationManager.m
//  MainAndMe
//
//  Created by Sasha on 4/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NotificationManager.h"
#import "NSURLConnectionDelegateHandler.h"
#import "APIv1_0.h"
#import "JSON.h"
#import "DataManager.h"


@interface NotificationManager()
@property (strong, nonatomic) NSArray* allNotifications;
@end


@implementation NotificationManager

#pragma mark - Shared Instance and Init
+ (NotificationManager *)shared {
    
    static NotificationManager *shared = nil;
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
    }
    return self;
}

#pragma mark - 
+ (void)loadNotificationsWithSuccess:(void(^) (NSArray* notif)) success
                             failure:(void(^) (NSError* error, NSString* errorString)) failure
                           exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] loadNotificationsWithSuccess:success
                                            failure:failure
                                          exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Notifications create");
    }

}

+ (void)addDeviceToken:(NSString*)token
               success:(void(^) (NSArray* obj)) success
               failure:(void(^) (NSError* error, NSString* errorString)) failure
             exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] addDeviceToken:token
                              success:success
                              failure:failure
                            exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Add Device create");
    }
}

+ (void)removeNotifications:(NSNumber*)number
                    success:(void(^) (id obj)) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception{
    
    @try {
        [[self shared] removeNotifications:number
                                   success:success
                                   failure:failure
                                 exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Remove Notification create");
    }
}

+ (void)removeNotificationsById:(NSNumber*)notifId
                        success:(void(^) (id obj)) success
                        failure:(void(^) (NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] removeNotificationsById:notifId
                                       success:success
                                       failure:failure
                                     exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Remove Notification create");
    }

}

#pragma mark -
- (void)addDeviceToken:(NSString*)token
               success:(void(^) (NSArray* obj)) success
               failure:(void(^) (NSError* error, NSString* errorString)) failure
             exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/devices?_token=%@&device[token]=%@", [APIv1_0 serverUrl], [DataManager shared].api_token, token];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:40];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([value isKindOfClass:[NSDictionary class]]) {
            success(value);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"error"];
            failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}


- (void)loadNotificationsWithSuccess:(void(^) (NSArray* notif)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/notifications?_token=%@", [APIv1_0 serverUrl], [DataManager shared].api_token];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:40];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([value isKindOfClass:[NSArray class]]) {
            
            NSMutableArray* temp = [NSMutableArray arrayWithArray:value];
            for (id obj in value) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    if ([[obj safeNumberObjectForKey:@"read"] intValue] == 1) {
                        [temp removeObject:obj];
                    }
                }
            }
            
            value = [NSArray arrayWithArray:temp];
            
            _allNotifications = value;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[_allNotifications count]];
            success(value);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"error"];
            failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}

- (void)removeNotifications:(NSNumber*)number
                    success:(void(^) (id obj)) success
                             failure:(void(^) (NSError* error, NSString* errorString)) failure
                           exception:(void(^) (NSString* exceptionString))exception{
    
    NSNumber* notifId =[self notificationIdByObjectId:number];
    [self removeNotification:number];
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/notifications/clear?_token=%@&id=%d", [APIv1_0 serverUrl], [DataManager shared].api_token, [notifId integerValue]];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:40];
    [request setHTTPMethod:@"DELETE"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([value isKindOfClass:[NSArray class]]) {
           
            NSInteger badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
            if (badgeNumber > 0) {
                badgeNumber--;
            }
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
            
            success(value);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"error"];
            failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}


- (void)removeNotificationsById:(NSNumber*)notifId
                    success:(void(^) (id obj)) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception{
    
    [self removeNotificationWithId:notifId];
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/notifications/clear?_token=%@&id=%d", [APIv1_0 serverUrl], [DataManager shared].api_token, [notifId integerValue]];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:40];
    [request setHTTPMethod:@"DELETE"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
       // id value = [returnString JSONValue];
        if ([returnString isEqualToString:@" "]) {
            
            NSInteger badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
            if (badgeNumber > 0) {
                badgeNumber--;
            }
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
            
            success(returnString);
        }else{
            NSString* messageString = returnString;
            failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}



- (BOOL)isContainId:(NSNumber*)number{
    for (id obj in _allNotifications) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSNumber* product_id = [obj safeNumberObjectForKey:@"product_id"];
            NSNumber* store_id = [obj safeNumberObjectForKey:@"store_id"];
            if ([product_id isEqualToNumber:number] || [store_id isEqualToNumber:number]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)removeNotification:(NSNumber*)number{
    NSMutableArray* temp = [NSMutableArray arrayWithArray:_allNotifications];
    
    for (id obj in _allNotifications) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSNumber* product_id = [obj safeNumberObjectForKey:@"product_id"];
            NSNumber* store_id = [obj safeNumberObjectForKey:@"store_id"];
            if ([product_id isEqualToNumber:number] || [store_id isEqualToNumber:number]) {
                [temp removeObject:obj];
            }
        }
    }
    _allNotifications = [NSArray arrayWithArray:temp];
}

- (void)removeNotificationWithId:(NSNumber*)number{
    NSMutableArray* temp = [NSMutableArray arrayWithArray:_allNotifications];
    
    for (id obj in _allNotifications) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSNumber* nitif_id = [obj safeNumberObjectForKey:@"id"];
            
            if ([nitif_id isEqualToNumber:number]) {
                [temp removeObject:obj];
            }
        }
    }
    _allNotifications = [NSArray arrayWithArray:temp];
}

- (NSNumber*)notificationIdByObjectId:(NSNumber*)number{
    
    for (id obj in _allNotifications) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSNumber* product_id = [obj safeNumberObjectForKey:@"product_id"];
            NSNumber* store_id = [obj safeNumberObjectForKey:@"store_id"];
            if ([product_id isEqualToNumber:number] || [store_id isEqualToNumber:number]) {
                return [obj safeNumberObjectForKey:@"id"];
            }
        }
    }
    return [NSNumber new];
}
@end
