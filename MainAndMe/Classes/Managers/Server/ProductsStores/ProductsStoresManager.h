//
//  ProductsManager.h
//  MainAndMe
//
//  Created by Sasha on 2/27/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


typedef enum {
    SearchTypeStores = 0,
    SearchTypeProducts
} SearchType;

typedef enum {
    SearchFilterPopular = 0,
    SearchFilterNewly,
    SearchFilterRandom,
    SearchFilterFututrd,
    SearchFilterNone
} SearchFilter;



@interface ProductsStoresManager : NSObject

@property (assign, nonatomic) SearchFilter lastSearchFilter;
@property (assign, nonatomic) SearchType lastSearchType;

+ (ProductsStoresManager*)shared;

+(void)loadPlaceInfo:(CGFloat)latnear
             lngnear:(CGFloat)lngnear
             success:(void(^) (NSString* name)) success
             failure:(void(^) (NSError* error, NSString* errorString)) failure
           exception:(void(^) (NSString* exceptionString))exception;

+(void)searchWithSearchType:(SearchType)type
               searchFilter:(SearchFilter)filter
                    success:(void(^) (NSArray* objects)) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception;

@end