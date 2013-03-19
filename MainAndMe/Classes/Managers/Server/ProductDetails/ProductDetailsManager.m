//
//  ProductDetailsManager.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductDetailsManager.h"
#import "APIv1_0.h"
#import "NSURLConnectionDelegateHandler.h"
#import "JSON.h"
#import "DataManager.h"

@interface ProductDetailsManager()

@end


@implementation ProductDetailsManager

#pragma mark - Shared Instance and Init
+ (ProductDetailsManager *)shared {
    
    static ProductDetailsManager *shared = nil;
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
+ (void)loadProfileInfoForUserIdNumber:(NSNumber*)userIdNumber
                               success:(void(^) (NSNumber* userIdNumber, NSDictionary* profile)) success
                               failure:(void(^) (NSNumber* userIdNumber, NSError* error, NSString* errorString)) failure
                             exception:(void(^) (NSNumber* userIdNumber, NSString* exceptionString))exception{
    @try {
        [[self shared] loadProfileInfoForUserIdNumber:userIdNumber
                                              success:success
                                              failure:failure
                                            exception:exception];
    }
    @catch (NSException *exc) {
        exception(userIdNumber, @"Exeption\n Load Profile create");
    }
}


+ (void)loadWishlistInfoForUser:(NSString*)userId
                        success:(void(^) (NSString* userId, NSArray* wishlist)) success
                        failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* userId, NSString* exceptionString))exception{

    @try {
        [[self shared] loadWishlistInfoForUser:userId
                                       success:success
                                       failure:failure
                                     exception:exception];
    }
    @catch (NSException *exc) {
        exception(userId, @"Exeption\n Load Wishlist create");
    }
}

+ (void)loadCommentsForUser:(NSString*)userId
                    success:(void(^) (NSString* userId, NSArray* commests)) success
                    failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* userId, NSString* exceptionString))exception{
    @try {
        [[self shared] loadCommentsForUser:userId
                                   success:success
                                   failure:failure
                                 exception:exception];
    }
    @catch (NSException *exc) {
        exception(userId, @"Exeption\n Load Comments create");
    }
}

+ (void)likeProducts:(NSString*)productId
             success:(void(^) ()) success
             failure:(void(^) (NSError* error, NSString* errorString)) failure
           exception:(void(^) (NSString* exceptionString))exception{
   
    @try {
        [[self shared] likeProducts:productId
                            success:success
                            failure:failure
                          exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Like Product create");
    }

}

+ (void)postComments:(NSString*)productId
             comment:(NSString*)comment
             success:(void(^) ()) success
             failure:(void(^) (NSError* error, NSString* errorString)) failure
           exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] postComments:productId
                            comment:comment
                            success:success
                            failure:failure
                          exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Post Comment create");
    }

}


+ (void)createWishlist:(NSString*)name
               success:(void(^) ()) success
               failure:(void(^) (NSError* error, NSString* errorString)) failure
             exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] createWishlist:name
                              success:success
                              failure:failure
                            exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Create Wishlist create");
    }
}


+ (void)addToWishlist:(NSString*)wishlistId
            productId:(NSString*)productId
              success:(void(^) ()) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] addToWishlist:wishlistId
                           productId:productId
                             success:success
                             failure:failure
                           exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Add To Wishlist create");
    }
}

- (void)loadProfileInfoForUserIdNumber:(NSNumber*)userIdNumber
                               success:(void(^) (NSNumber* userIdNumber, NSDictionary* profile)) success
                               failure:(void(^) (NSNumber* userIdNumber, NSError* error, NSString* errorString)) failure
                             exception:(void(^) (NSNumber* userIdNumber, NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users/%@", [APIv1_0 serverUrl], [userIdNumber stringValue]];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isDataValid:value]) {
            success(userIdNumber, value);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"error"];
            failure(userIdNumber, nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(userIdNumber, error, error.localizedDescription);
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(userIdNumber, exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}

- (void)loadWishlistInfoForUser:(NSString*)userId
                        success:(void(^) (NSString* userId, NSArray* wishlist)) success
                        failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* userId, NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users/%@/product_lists", [APIv1_0 serverUrl], userId];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isWishlistDataValid:value]) {
            success(userId, value);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"error"];
            failure(userId, nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(userId, error, error.localizedDescription);
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(userId, exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}

- (void)loadCommentsForUser:(NSString*)userId
                    success:(void(^) (NSString* userId, NSArray* commests)) success
                    failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* userId, NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/products/%@/comments", [APIv1_0 serverUrl], userId];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isWishlistDataValid:value]) {
            success(userId, value);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"error"];
            failure(userId, nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(userId, error, error.localizedDescription);
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(userId, exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}


- (void)likeProducts:(NSString*)productId
             success:(void(^) ()) success
             failure:(void(^) (NSError* error, NSString* errorString)) failure
           exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/products/%@/likes?token=%@", [APIv1_0 serverUrl], productId, [DataManager shared].api_token];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isDataValid:value]) {
            if ([value safeObjectForKey:@"errors"] == nil) {
                success();
            }else{
                NSString* messageString = [[[value safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:@"base"] safeStringObjectAtIndex:0];
                failure(nil, messageString);
            }
            
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

- (void)postComments:(NSString*)productId
             comment:(NSString*)comment
             success:(void(^) ()) success
             failure:(void(^) (NSError* error, NSString* errorString)) failure
           exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/products/%@/comments?token=%@&comment[body]=%@", [APIv1_0 serverUrl], productId, [DataManager shared].api_token, comment];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isDataValid:value]) {
            if ([value safeObjectForKey:@"errors"] == nil) {
                success();
            }else{
                NSString* messageString = [[[value safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:@"base"] safeStringObjectAtIndex:0];
                failure(nil, messageString);
            }
            
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



- (void)createWishlist:(NSString*)name
               success:(void(^) ()) success
               failure:(void(^) (NSError* error, NSString* errorString)) failure
             exception:(void(^) (NSString* exceptionString))exception{
    //   users/%@/product_lists?_token=%@&product_list[name]=%@";
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users/%@/product_lists?_token=%@&product_list[name]=%@", [APIv1_0 serverUrl], [DataManager shared].userId, [DataManager shared].api_token, name];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isDataValid:value]) {
            if ([value safeObjectForKey:@"errors"] == nil) {
                success();
            }else{
                NSString* messageString = [[[[value safeDictionaryObjectForKey:@"errors"] allValues] safeArrayObjectAtIndex:0] safeStringObjectAtIndex:0];
                failure(nil, messageString);
            }
            
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

- (void)addToWishlist:(NSString*)wishlistId
            productId:(NSString*)productId
               success:(void(^) ()) success
               failure:(void(^) (NSError* error, NSString* errorString)) failure
             exception:(void(^) (NSString* exceptionString))exception{

    NSString* urlString =
    [NSString stringWithFormat:@"%@/product_lists/%@/list_items?_token=%@&list_item[product_id]=%@", [APIv1_0 serverUrl], wishlistId, [DataManager shared].api_token, productId];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isDataValid:value]) {
            if ([value safeObjectForKey:@"errors"] == nil) {
                success();
            }else{
                NSString* messageString = [[[value safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:@"product"] safeStringObjectAtIndex:0];
                failure(nil, messageString);
            }
            
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




#pragma mark - Privat Methods
//! Validate request
- (BOOL)isDataValid:(id)value{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = (NSDictionary*)value;
        NSString* message = [dict safeStringObjectForKey:@"message"];
        if (message.length > 0) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

//! Validate request
- (BOOL)isWishlistDataValid:(id)value{
    if ([value isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return NO;
}



@end
