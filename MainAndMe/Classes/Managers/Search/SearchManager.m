//
//  SearchManager.m
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SearchManager.h"
#import "APIv1_0.h"
#import "NSURLConnectionDelegateHandler.h"
#import "JSON.h"


@interface SearchManager()

@end


@implementation SearchManager

#pragma mark - Shared Instance and Init
+ (SearchManager *)shared {
    
    static SearchManager *shared = nil;
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

+ (void)loadCcategiriesSuccess:(void(^) (NSArray* categories)) success
                       failure:(void(^) (NSError* error, NSString* errorString)) failure
                     exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadCcategiriesSuccess:success
                                      failure:failure
                                    exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Categories create");
    }

}

//! Load Stores For Category
+ (void)loadStoresForCategory:(NSString*)categoryId
                      success:(void(^) (NSArray* objects)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadStoresForCategory:categoryId
                                     success:success
                                     failure:failure
                                   exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Stores for Category create");
    }

}

//! Load Stores For All Category
+ (void)loadStoresForAllCategoryWithSuccess:(void(^) (NSArray* objects)) success
                                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                                  exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadStoresForAllCategoryWithSuccess:success
                                                   failure:failure
                                                 exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Stores for All Category create");
    }


}

+ (void)loadStatesSuccess:(void(^) (NSDictionary* states)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] loadStatesSuccess:success
                                 failure:failure
                               exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load States create");
    }
}

+ (void)loadCommunityForState:(NSString*)state
                      success:(void(^) (NSArray* communities)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadCommunityForState:state
                                     success:success
                                     failure:failure
                                   exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Community create");
    }
}

//! Load Likes For Products
+ (void)loadProductLikesForUser:(NSString*)userId
                        success:(void(^) (NSArray* objects)) success
                        failure:(void(^) (NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] loadProductLikesForUser:userId
                                       success:success
                                       failure:failure
                                     exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Likes For Products create");
    }
}


//! Load Wishlist
+ (void)loadWishlistById:(NSString*)wishlistId
                 success:(void(^) (NSArray* objects)) success
                 failure:(void(^) (NSError* error, NSString* errorString)) failure
               exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadWishlistById:wishlistId
                                success:success
                                failure:failure
                              exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Wishlist Info create");
    }
}


#pragma mark - 
- (void)loadCcategiriesSuccess:(void(^) (NSArray* categories)) success
                       failure:(void(^) (NSError* error, NSString* errorString)) failure
                     exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/categories", [APIv1_0 serverUrl]];
    
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

//! Load Stores For Category
-(void)loadStoresForCategory:(NSString*)categoryId
                    success:(void(^) (NSArray* objects)) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString = [NSString stringWithFormat:@"%@/categories/%@/stores", [APIv1_0 serverUrl], categoryId];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        
        if ([value isKindOfClass:[NSArray class]]) {
            
            success(value);
            
        }else{
            NSString* messageString = @"Server API Error";
            
            failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    } eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}

//! Load Wishlist
- (void)loadWishlistById:(NSString*)wishlistId
                 success:(void(^) (NSArray* objects)) success
                 failure:(void(^) (NSError* error, NSString* errorString)) failure
               exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString = [NSString stringWithFormat:@"%@/product_lists/%@/list_items", [APIv1_0 serverUrl], wishlistId];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        
        if ([value isKindOfClass:[NSArray class]]) {
            
            success(value);
            
        }else{
            NSString* messageString = @"Server API Error";
            
            failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    } eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
}

//! Load Stores For Category
-(void)loadProductLikesForUser:(NSString*)userId
                       success:(void(^) (NSArray* objects)) success
                       failure:(void(^) (NSError* error, NSString* errorString)) failure
                     exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString = [NSString stringWithFormat:@"%@/users/%@/products/likes", [APIv1_0 serverUrl], userId];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        
        if ([value isKindOfClass:[NSArray class]]) {
            
            success(value);
            
        }else{
            NSString* messageString = @"Server API Error";
            
            failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    } eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}

//! Load Stores For All Category
-(void)loadStoresForAllCategoryWithSuccess:(void(^) (NSArray* objects)) success
                                   failure:(void(^) (NSError* error, NSString* errorString)) failure
                                 exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString = [NSString stringWithFormat:@"%@/stores", [APIv1_0 serverUrl]];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        
        if ([value isKindOfClass:[NSArray class]]) {
            
            success(value);
            
        }else{
            NSString* messageString = @"Server API Error";
            
            failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    } eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}


#pragma mark -
- (void)loadStatesSuccess:(void(^) (NSDictionary* states)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/states", [APIv1_0 serverUrl]];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
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

#pragma mark -
- (void)loadCommunityForState:(NSString*)state
                      success:(void(^) (NSArray* communities)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/search_state_communities?name=%@", [APIv1_0 serverUrl], state];
    
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


- (BOOL)isDataValid:(id)value{
    if ([value isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return NO;
}

@end
