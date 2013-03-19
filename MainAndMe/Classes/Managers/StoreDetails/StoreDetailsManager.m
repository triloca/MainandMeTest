//
//  StoreDetailsManager.m
//  MainAndMe
//
//  Created by Sasha on 3/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "StoreDetailsManager.h"
#import "NSURLConnectionDelegateHandler.h"
#import "APIv1_0.h"
#import "JSON.h"
#import "DataManager.h"


@interface StoreDetailsManager()

@end


@implementation StoreDetailsManager

#pragma mark - Shared Instance and Init
+ (StoreDetailsManager *)shared {
    
    static StoreDetailsManager *shared = nil;
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


+ (void)loadProductsForStore:(NSString*)storeId
                     success:(void(^) (NSArray* products)) success
                     failure:(void(^) (NSError* error, NSString* errorString)) failure
                   exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] loadProductsForStore:storeId
                                    success:success
                                    failure:failure
                                  exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Products create");
    }
}

+ (void)likeStore:(NSString*)storeId
          success:(void(^) ()) success
          failure:(void(^) (NSError* error, NSString* errorString)) failure
        exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] likeStore:storeId
                         success:success
                         failure:failure
                       exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Like Store create");
    }
}

+ (void)followStore:(NSString*)storeId
            success:(void(^) ()) success
            failure:(void(^) (NSError* error, NSString* errorString)) failure
          exception:(void(^) (NSString* exceptionString))exception{
    
    @try {
        [[self shared] followStore:storeId
                           success:success
                           failure:failure
                         exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Follow Store create");
    }
}

+ (void)rateStore:(NSString*)storeId
             rate:(NSInteger)rate
          success:(void(^) ()) success
          failure:(void(^) (NSError* error, NSString* errorString)) failure
        exception:(void(^) (NSString* exceptionString))exception{
  
    @try {
        [[self shared] rateStore:storeId
                            rate:rate
                         success:success
                         failure:failure
                       exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Rate Store create");
    }
}

#pragma mark -

- (void)loadProductsForStore:(NSString*)storeId
                    success:(void(^) (NSArray* products)) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/stores/%@/products", [APIv1_0 serverUrl], storeId];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isProductsDataValid:value]) {
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


- (void)likeStore:(NSString*)storeId
          success:(void(^) ()) success
          failure:(void(^) (NSError* error, NSString* errorString)) failure
        exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/stores/%@/likes?token=%@", [APIv1_0 serverUrl], storeId, [DataManager shared].api_token];
    
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

- (void)followStore:(NSString*)storeId
            success:(void(^) ()) success
            failure:(void(^) (NSError* error, NSString* errorString)) failure
          exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/follow/store/%@?token=%@", [APIv1_0 serverUrl], storeId, [DataManager shared].api_token];
    
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


- (void)rateStore:(NSString*)storeId
             rate:(NSInteger)rate
          success:(void(^) ()) success
          failure:(void(^) (NSError* error, NSString* errorString)) failure
        exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/stores/%@/rate?token=%@&rate=%d", [APIv1_0 serverUrl], storeId, [DataManager shared].api_token, rate];
    
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
- (BOOL)isProductsDataValid:(id)value{
    if ([value isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return NO;
}


@end
