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
@end