//
//  SearchManager.m
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SearchManager.h"
#import "NSURLConnectionDelegateHandler.h"
#import "JSON.h"
#import "LocationManager.h"

NSString * const kkkServerBaseURL = @"http://www.mainandme.com/api/v1";

@interface SearchManager()
@property (strong, nonatomic) NSURLConnection* currentSearchConnection;
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
        
        [self loadCommunityValues];
        if (self.state == nil || self.city == nil || self.communityID == nil || self.communityLocation == nil) {
            [self loadDefaultValues];
        }
    }
    return self;
}

/*
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

//! Load Stores For Key
+ (void)loadStoresForKey:(NSString*)key
                success:(void(^) (NSArray* objects)) success
                failure:(void(^) (NSError* error, NSString* errorString)) failure
               exception:(void(^) (NSString* exceptionString))exception{
   
    
    @try {
        [[self shared] loadStoresForKey:key
                                success:success
                                failure:failure
                              exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Stores for Key");
    }
}


//! Load Stores For Key
+ (void)loadProductsForKey:(NSString*)key
                   success:(void(^) (NSArray* objects)) success
                   failure:(void(^) (NSError* error, NSString* errorString)) failure
                 exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadProductsForKey:key
                                  success:success
                                  failure:failure
                                exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Products for Key");
    }
}

//! Load Products For Category
+ (void)loadProductsForCategory:(NSString*)categoryId
                      success:(void(^) (NSArray* objects)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadProductsForCategory:categoryId
                                     success:success
                                     failure:failure
                                   exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Products for Category create");
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

*/

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
                         page:(NSInteger)page
                      success:(void(^) (NSArray* communities)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadCommunityForState:state
                                        page:(NSInteger)page
                                     success:success
                                     failure:failure
                                   exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Community create");
    }
}


//! Load Community By ID
+ (void)loadCommunityById:(NSNumber*)communityId
                  success:(void(^) (NSDictionary* communitie)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] loadCommunityById:communityId
                                 success:success
                                 failure:failure
                               exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Community By ID create");
    }

}


/*
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

//! Load Products For All Category
+ (void)loadProductsForAllCategoryWithSuccess:(void(^) (NSArray* objects)) success
                                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                                    exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] loadProductsForAllCategoryWithSuccess:success
                                                     failure:failure
                                                   exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Products For All Categories create");
    }
}
*/

/*

#pragma mark -
- (void)loadCcategiriesSuccess:(void(^) (NSArray* categories)) success
                       failure:(void(^) (NSError* error, NSString* errorString)) failure
                     exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/categories", kkServerBaseURL];
    
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
    
    NSString* urlString = [NSString stringWithFormat:@"%@/categories/%@/stores", kkServerBaseURL, categoryId];
    
    NSString* communityId = [LocationManager shared].communityId;
    urlString = [urlString stringByAppendingFormat:@"?community_id=%@", communityId];

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
-(void)loadProductsForCategory:(NSString*)categoryId
                       success:(void(^) (NSArray* objects)) success
                       failure:(void(^) (NSError* error, NSString* errorString)) failure
                     exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString = [NSString stringWithFormat:@"%@/categories/%@/products", kkServerBaseURL, categoryId];
    
    NSString* communityId = [LocationManager shared].communityId;
    urlString = [urlString stringByAppendingFormat:@"?community_id=%@", communityId];
    
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
    
    NSString* urlString = [NSString stringWithFormat:@"%@/product_lists/%@/list_items", kkServerBaseURL, wishlistId];
    
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
    
    NSString* urlString = [NSString stringWithFormat:@"%@/users/%@/products/likes", kkServerBaseURL, userId];
    
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
    
    NSString* urlString = [NSString stringWithFormat:@"%@/stores", kkServerBaseURL];
    
    NSString* communityId = [LocationManager shared].communityId;
    urlString = [urlString stringByAppendingFormat:@"?community_id=%@", communityId];
    
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

//! Load Stores For Key
-(void)loadStoresForKey:(NSString*)key
                success:(void(^) (NSArray* objects)) success
                failure:(void(^) (NSError* error, NSString* errorString)) failure
              exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString = [NSString stringWithFormat:@"%@/stores?keywords=%@", kkServerBaseURL, key];
    
    NSString* communityId = [LocationManager shared].communityId;
    urlString = [urlString stringByAppendingFormat:@"&community_id=%@", communityId];
    
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
    _currentSearchConnection = connection;
    [connection start];
    
}

//! Load Stores For Key
-(void)loadProductsForKey:(NSString*)key
                  success:(void(^) (NSArray* objects)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString = [NSString stringWithFormat:@"%@/products?keywords=%@", kkServerBaseURL, key];
    
    NSString* communityId = [LocationManager shared].communityId;
    urlString = [urlString stringByAppendingFormat:@"&community_id=%@", communityId];
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
    _currentSearchConnection = connection;
    [connection start];
    
}


- (void)cancelSearch{
    [_currentSearchConnection cancel];
}

//! Load Products For All Category
-(void)loadProductsForAllCategoryWithSuccess:(void(^) (NSArray* objects)) success
                                     failure:(void(^) (NSError* error, NSString* errorString)) failure
                                   exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString = [NSString stringWithFormat:@"%@/products/nearby?lat=%f&lng=%f", kkServerBaseURL,
                           [LocationManager shared].currentLocation.coordinate.latitude,
                           [LocationManager shared].currentLocation.coordinate.longitude];
    
    NSString* communityId = [LocationManager shared].communityId;
    urlString = [urlString stringByAppendingFormat:@"&community_id=%@", communityId];
    
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

*/

#pragma mark -
- (void)loadStatesSuccess:(void(^) (NSDictionary* states)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/states", kkkServerBaseURL];
    
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
                         page:(NSInteger)page
                      success:(void(^) (NSArray* communities)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    //[NSString stringWithFormat:@"%@/search_state_communities?name=%@&page=%d&per_page=40", [APIv1_0 serverUrl], state, page];
    [NSString stringWithFormat:@"%@/search_state_communities?name=%@&compact=true", kkkServerBaseURL, state];
    
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


- (void)loadCommunityById:(NSNumber*)communityId
                      success:(void(^) (NSDictionary* communitie)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    //[NSString stringWithFormat:@"%@/search_state_communities?name=%@&page=%d&per_page=40", [APIv1_0 serverUrl], state, page];
    [NSString stringWithFormat:@"%@/communities/%d", kkkServerBaseURL, [communityId intValue]];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:40];
    [request setHTTPMethod:@"GET"];
    
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


- (BOOL)isDataValid:(id)value{
    if ([value isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return NO;
}


- (void)loadDefaultValues{
    self.state = @"MA";
    self.city = @"Roslindale";
    self.communityID = @"17005";
    self.communityLocation = [[CLLocation alloc] initWithLatitude:42.283215 longitude:-71.123029];
}

- (void)loadCommunityValues{
    self.state = [[NSUserDefaults standardUserDefaults] stringForKey:@"kStateName"];
    self.stateName = [[NSUserDefaults standardUserDefaults] stringForKey:@"kStateFullName"];

    self.city = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCityName"];
    self.communityID = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCommunityID"];
    
    CLLocationDegrees lat = [[NSUserDefaults standardUserDefaults] doubleForKey:@"kLocationLat"];
    CLLocationDegrees lng = [[NSUserDefaults standardUserDefaults] doubleForKey:@"kLocationLng"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    self.communityLocation = location;
}


- (void)setState:(NSString *)state{
    _state = state;
    [[NSUserDefaults standardUserDefaults] setObject:state forKey:@"kStateName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setStateName:(NSString *)stateName{
    _stateName = stateName;
    [[NSUserDefaults standardUserDefaults] setObject:stateName forKey:@"kStateFullName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setCity:(NSString *)city{
    _city = city;
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:@"kCityName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCommunityID:(NSString *)communityID{
    _communityID = communityID;
    [[NSUserDefaults standardUserDefaults] setObject:communityID forKey:@"kCommunityID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCommunityLocation:(CLLocation *)communityLocation{
    _communityLocation = communityLocation;
    
    [[NSUserDefaults standardUserDefaults] setDouble:communityLocation.coordinate.latitude forKey:@"kLocationLat"];
    [[NSUserDefaults standardUserDefaults] setDouble:communityLocation.coordinate.longitude forKey:@"kLocationLng"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
