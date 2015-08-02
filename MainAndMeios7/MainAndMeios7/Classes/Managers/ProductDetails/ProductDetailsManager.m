//
//  ProductDetailsManager.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductDetailsManager.h"
#import "NSURLConnectionDelegateHandler.h"
#import "JSON.h"
#import "SearchManager.h"

NSString * const kkServerBaseURL = @"http://www.mainandme.com/api/v1";


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

+ (void)deleteWishlistInfoForUser:(NSString*)userId
                        productID:(NSString*)productID
                          success:(void(^) (NSString* userId, NSArray* wishlist)) success
                          failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                        exception:(void(^) (NSString* userId, NSString* exceptionString))exception{
    @try {
        [[self shared] deleteWishlistInfoForUser:userId
                                       productID:productID
                                         success:success
                                         failure:failure
                                       exception:exception];
    }
    @catch (NSException *exc) {
        exception(userId, @"Exeption\n Delete Wishlist create");
    }


}

+ (void)deleteProduct:itemId
           inWishlist:wishlistId
              success:(void(^) (NSArray* wishlist)) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] deleteProduct:itemId
                          inWishlist:wishlistId
                             success:success
                             failure:failure
                           exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Delete Wishlist Item create");
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

+ (void)loadStoreCommentsForUser:(NSString*)userId
                         success:(void(^) (NSString* userId, NSArray* commests)) success
                         failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                       exception:(void(^) (NSString* userId, NSString* exceptionString))exception{
    @try {
        [[self shared] loadStoreCommentsForUser:userId
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

+ (void)postProductComments:(NSString*)productId
                    comment:(NSString*)comment
                    success:(void(^) ()) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception{
    
    @try {
        [[self shared] postProductComments:productId
                                   comment:comment
                                   success:success
                                   failure:failure
                                 exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Post Comment create");
    }
    
}

+ (void)postStoreComments:(NSString*)productId
                  comment:(NSString*)comment
                  success:(void(^) ()) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{
    
    @try {
        [[self shared] postStoreComments:productId
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
               success:(void(^) (NSDictionary *newWishlist)) success
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
    [NSString stringWithFormat:@"%@/users/%@", kkServerBaseURL, [userIdNumber stringValue]];
   
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
    [NSString stringWithFormat:@"%@/users/%@/product_lists", kkServerBaseURL, userId];
    
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

- (void)deleteWishlistInfoForUser:(NSString*)userId
                        productID:(NSString*)productID
                        success:(void(^) (NSString* userId, NSArray* wishlist)) success
                        failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* userId, NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users/%@/product_lists/%@", kkServerBaseURL, userId, productID];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"DELETE"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if (value == nil) {
            if (success)
                success(userId, value);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"error"];
            if (failure)
                failure(userId, nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        if (failure)
            failure(userId, error, error.localizedDescription);
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        if (exception)
            exception(userId, exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}

- (void)deleteProduct:itemId
           inWishlist:wishlistId
              success:(void(^) (NSArray* wishlist)) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/product_lists/%@/list_items/%@", kkServerBaseURL, wishlistId, itemId];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"DELETE"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([value isKindOfClass:[NSDictionary class]]) {
            if (success)
                success(value);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"error"];
            if (failure)
                failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        if (failure)
            failure(error, error.localizedDescription);
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        if (exception)
            exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}





- (void)loadCommentsForUser:(NSString*)userId
                    success:(void(^) (NSString* userId, NSArray* commests)) success
                    failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* userId, NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/products/%@/comments", kkServerBaseURL, userId];
    
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

- (void)loadStoreCommentsForUser:(NSString*)userId
                         success:(void(^) (NSString* userId, NSArray* commests)) success
                         failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                       exception:(void(^) (NSString* userId, NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/stores/%@/comments", kkServerBaseURL, userId];
    
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
    [NSString stringWithFormat:@"%@/products/%@/likes?_token=%@", kkServerBaseURL, productId, [CommonManager shared].apiToken];
    
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

- (void)postProductComments:(NSString*)productId
                    comment:(NSString*)comment
                    success:(void(^) ()) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/products/%@/comments?_token=%@&comment[body]=%@", kkServerBaseURL, productId, [CommonManager shared].apiToken, comment];
    
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

- (void)postStoreComments:(NSString*)productId
                  comment:(NSString*)comment
                  success:(void(^) ()) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/stores/%@/comments?_token=%@&comment[body]=%@", kkServerBaseURL, productId, [CommonManager shared].apiToken, comment];
    
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
               success:(void(^) (NSDictionary *newWishlist)) success
               failure:(void(^) (NSError* error, NSString* errorString)) failure
             exception:(void(^) (NSString* exceptionString))exception{
    //   users/%@/product_lists?_token=%@&product_list[name]=%@";
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users/%@/product_lists?_token=%@&product_list[name]=%@", kkServerBaseURL, [CommonManager shared].userId, [CommonManager shared].apiToken, name];
    
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
                success(value);
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
    [NSString stringWithFormat:@"%@/product_lists/%@/list_items?_token=%@&list_item[product_id]=%@", kkServerBaseURL, wishlistId, [CommonManager shared].apiToken, productId];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSLog(@"URL: %@", urlString);
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



- (void)trackLoginSuccess:(void(^)()) success
                        failure:(void(^) (NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/login_trackers?_token=%@&community_id=%@", kkServerBaseURL, [CommonManager shared].apiToken, [SearchManager shared].communityID];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        //id value = [returnString JSONValue];
            success();
        
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
