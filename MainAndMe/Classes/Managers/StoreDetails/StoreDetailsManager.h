//
//  StoreDetailsManager.h
//  MainAndMe
//
//  Created by Sasha on 3/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface StoreDetailsManager : NSObject

+ (StoreDetailsManager*)shared;
+ (void)loadProductsForStore:(NSString*)storeId
                     success:(void(^) (NSArray* products)) success
                     failure:(void(^) (NSError* error, NSString* errorString)) failure
                   exception:(void(^) (NSString* exceptionString))exception;

+ (void)likeStore:(NSString*)storeId
          success:(void(^) ()) success
          failure:(void(^) (NSError* error, NSString* errorString)) failure
        exception:(void(^) (NSString* exceptionString))exception;

+ (void)followStore:(NSString*)storeId
            success:(void(^) ()) success
            failure:(void(^) (NSError* error, NSString* errorString)) failure
          exception:(void(^) (NSString* exceptionString))exception;

+ (void)rateStore:(NSString*)storeId
             rate:(NSInteger)rate
          success:(void(^) ()) success
          failure:(void(^) (NSError* error, NSString* errorString)) failure
        exception:(void(^) (NSString* exceptionString))exception;

+ (void)loadStoreByStoreId:(NSString*)storeId
                   success:(void(^) (NSDictionary* store)) success
                   failure:(void(^) (NSError* error, NSString* errorString)) failure
                 exception:(void(^) (NSString* exceptionString))exception;

+ (void)loadProductByProductId:(NSString*)productId
                       success:(void(^) (NSDictionary* store)) success
                       failure:(void(^) (NSError* error, NSString* errorString)) failure
                     exception:(void(^) (NSString* exceptionString))exception;

@end