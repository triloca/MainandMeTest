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

+ (void)loadPlaceInfo:(CGFloat)latnear
              lngnear:(CGFloat)lngnear
              success:(void(^) (NSString* name, NSString* prefix)) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception;

+ (void)searchWithSearchType:(SearchType)type
                searchFilter:(SearchFilter)filter
                        page:(NSInteger)page
                     success:(void(^) (NSArray* objects)) success
                     failure:(void(^) (NSError* error, NSString* errorString)) failure
                   exception:(void(^) (NSString* exceptionString))exception;


+ (void)uploadProductWithName:(NSString*)name
                        price:(NSString*)price
                     category:(NSString*)category
                    storeName:(NSString*)storeName
                  description:(NSString*)description
                        image:(UIImage*)image
                      success:(void(^) (NSDictionary* object)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception;


//! Upload Store
+ (void)uploadStoreWithName:(NSString*)name
                    country:(NSString*)country
                      state:(NSString*)state
                     street:(NSString*)street
                       city:(NSString*)city
                   category:(NSString*)category
                    zipCode:(NSString*)zipCode
                description:(NSString*)description
                      image:(UIImage*)image
                    success:(void(^) (NSDictionary* object)) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception;
@end