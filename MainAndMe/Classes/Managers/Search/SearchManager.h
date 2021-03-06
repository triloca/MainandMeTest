//
//  SearchManager.h
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface SearchManager : NSObject

+ (SearchManager*)shared;
+ (void)loadCcategiriesSuccess:(void(^) (NSArray* categories)) success
                       failure:(void(^) (NSError* error, NSString* errorString)) failure
                     exception:(void(^) (NSString* exceptionString))exception;

//! Load Stores For Category
+ (void)loadStoresForCategory:(NSString*)categoryId
                      success:(void(^) (NSArray* objects)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception;

//! Load Stores For All Category
+ (void)loadStoresForAllCategoryWithSuccess:(void(^) (NSArray* objects)) success
                                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                                  exception:(void(^) (NSString* exceptionString))exception;
//! Load All States
+ (void)loadStatesSuccess:(void(^) (NSDictionary* states)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception;

//! Load Community For State
+ (void)loadCommunityForState:(NSString*)state
                         page:(NSInteger)page
                      success:(void(^) (NSArray* communities)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception;

//! Load Community By ID
+ (void)loadCommunityById:(NSNumber*)communityId
                  success:(void(^) (NSDictionary* communitie)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception;

//! Load Stores For Category
+ (void)loadProductLikesForUser:(NSString*)userId
                        success:(void(^) (NSArray* objects)) success
                        failure:(void(^) (NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* exceptionString))exception;

//! Load Wishlist
+ (void)loadWishlistById:(NSString*)wishlistId
                 success:(void(^) (NSArray* objects)) success
                 failure:(void(^) (NSError* error, NSString* errorString)) failure
               exception:(void(^) (NSString* exceptionString))exception;

//! Load Products For All Category
+ (void)loadProductsForAllCategoryWithSuccess:(void(^) (NSArray* objects)) success
                                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                                    exception:(void(^) (NSString* exceptionString))exception;

//! Load Products For Category
+ (void)loadProductsForCategory:(NSString*)categoryId
                        success:(void(^) (NSArray* objects)) success
                        failure:(void(^) (NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* exceptionString))exception;

//! Load Stores For Key
+ (void)loadStoresForKey:(NSString*)key
                 success:(void(^) (NSArray* objects)) success
                 failure:(void(^) (NSError* error, NSString* errorString)) failure
               exception:(void(^) (NSString* exceptionString))exception;

//! Load Stores For Key
+ (void)loadProductsForKey:(NSString*)key
                   success:(void(^) (NSArray* objects)) success
                   failure:(void(^) (NSError* error, NSString* errorString)) failure
                 exception:(void(^) (NSString* exceptionString))exception;

- (void)cancelSearch;

@end