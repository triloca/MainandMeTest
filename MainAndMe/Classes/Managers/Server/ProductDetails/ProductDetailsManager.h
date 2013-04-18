//
//  ProductDetailsManager.h
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface ProductDetailsManager : NSObject

+ (ProductDetailsManager*)shared;

+ (void)loadProfileInfoForUserIdNumber:(NSNumber*)userIdNumber
                               success:(void(^) (NSNumber* userIdNumber, NSDictionary* profile)) success
                               failure:(void(^) (NSNumber* userIdNumber, NSError* error, NSString* errorString)) failure
                             exception:(void(^) (NSNumber* userIdNumber, NSString* exceptionString))exception;

+ (void)loadWishlistInfoForUser:(NSString*)userId
                        success:(void(^) (NSString* userId, NSArray* wishlist)) success
                        failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* userId, NSString* exceptionString))exception;

+ (void)deleteWishlistInfoForUser:(NSString*)userId
                        productID:(NSString*)productID
                          success:(void(^) (NSString* userId, NSArray* wishlist)) success
                          failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                        exception:(void(^) (NSString* userId, NSString* exceptionString))exception;

+ (void)deleteProduct:itemId
           inWishlist:wishlistId
              success:(void(^) (NSArray* wishlist)) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception;

+ (void)loadCommentsForUser:(NSString*)userId
                    success:(void(^) (NSString* userId, NSArray* commests)) success
                    failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* userId, NSString* exceptionString))exception;

+ (void)loadStoreCommentsForUser:(NSString*)userId
                         success:(void(^) (NSString* userId, NSArray* commests)) success
                         failure:(void(^) (NSString* userId, NSError* error, NSString* errorString)) failure
                       exception:(void(^) (NSString* userId, NSString* exceptionString))exception;


+ (void)likeProducts:(NSString*)productId
             success:(void(^) ()) success
             failure:(void(^) (NSError* error, NSString* errorString)) failure
           exception:(void(^) (NSString* exceptionString))exception;

+ (void)postProductComments:(NSString*)productId
                    comment:(NSString*)comment
                    success:(void(^) ()) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception;

+ (void)postStoreComments:(NSString*)productId
                  comment:(NSString*)comment
                  success:(void(^) ()) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception;

+ (void)createWishlist:(NSString*)name
               success:(void(^) ()) success
               failure:(void(^) (NSError* error, NSString* errorString)) failure
             exception:(void(^) (NSString* exceptionString))exception;

+ (void)addToWishlist:(NSString*)wishlistId
            productId:(NSString*)productId
              success:(void(^) ()) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception;


@end