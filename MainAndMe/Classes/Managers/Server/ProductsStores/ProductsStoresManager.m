//
//  ProductsManager.m
//  MainAndMe
//
//  Created by Sasha on 2/27/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductsStoresManager.h"
#import "NSURLConnectionDelegateHandler.h"
#import "APIv1_0.h"
#import "NSDictionary+Safe.h"
#import "NSArray+Safe.h"
#import "JSON.h"
#import <CoreLocation/CoreLocation.h> 
#import "LocationManager.h"
#import "DataManager.h"
#import "NSData+Base64.h"


@interface ProductsStoresManager()

@end


@implementation ProductsStoresManager

#pragma mark - Shared Instance and Init
+ (ProductsStoresManager *)shared {
    
    static ProductsStoresManager *shared = nil;
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
        _lastSearchFilter = SearchFilterNone;
    }
    return self;
}

#pragma mark - 
//! Load place info
+ (void)loadPlaceInfo:(CGFloat)latnear
              lngnear:(CGFloat)lngnear
              success:(void(^) (NSString* name, NSString* prefix)) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadPlaceInfo:latnear
                             lngnear:lngnear
                             success:success
                             failure:failure
                           exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Place Info create");
    }
}

//! Search with type
+ (void)searchWithSearchType:(SearchType)type
                searchFilter:(SearchFilter)filter
                     success:(void(^) (NSArray* objects)) success
                     failure:(void(^) (NSError* error, NSString* errorString)) failure
                   exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] searchWithSearchType:type
                               searchFilter:filter
                                    success:success
                                    failure:failure
                                  exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Search With Type create");
    }
}

//! Search with type
+ (void)uploadItemWithType:(NSString*)type
                     price:(NSString*)price
                  category:(NSString*)category
                      name:(NSString*)name
                 storeName:(NSString*)storeName
               description:(NSString*)description
                     image:(UIImage*)image
                   success:(void(^) (NSDictionary* object)) success
                   failure:(void(^) (NSError* error, NSString* errorString)) failure
                 exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] uploadItemWithType:type
                                    price:price
                                 category:category
                                     name:name
                                storeName:storeName
                              description:description
                                    image:image
                                  success:success
                                  failure:failure
                                exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Upload Item create");
    }
}

#pragma mark - 
//! Load place info
-(void)loadPlaceInfo:(CGFloat)latnear
             lngnear:(CGFloat)lngnear
              success:(void(^) (NSString* name, NSString* prefix)) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception{
    
    
//    latnear = 37.683039;
//    lngnear = -92.666373;
    //"http://ws.geonames.org/findNearbyPostalCodes?lat=%f&lng=%f"
    NSString* urlString =
    [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false", latnear, lngnear];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
       
        
        NSArray* postalCodes = [value safeArrayObjectForKey:@"results"];
        NSDictionary* dict = [postalCodes safeDictionaryObjectAtIndex:0];
        NSArray* address_components = [dict safeArrayObjectForKey:@"address_components"];
        
        NSString* cityName = @"";
        NSString* statePrefix = @"";
        NSString* statePrefixHalp = @"";
        
        
        for (id obj in address_components) {
            NSDictionary* address_dict = (NSDictionary*)obj;
            if ([[address_dict safeArrayObjectForKey:@"types"] containsObject:@"administrative_area_level_1"]) {
                statePrefix = [address_dict safeStringObjectForKey:@"short_name"];
            }
            if ([[address_dict safeArrayObjectForKey:@"types"] containsObject:@"locality"]) {
                cityName = [address_dict safeStringObjectForKey:@"long_name"];
                statePrefixHalp = [address_dict safeStringObjectForKey:@"short_name"];
            }
        }
        if (statePrefix.length > 2) {
            statePrefix = statePrefixHalp;
        }
        success(cityName, statePrefix);
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    } eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
}

//! Search with type
-(void)searchWithSearchType:(SearchType)type
               searchFilter:(SearchFilter)filter
                    success:(void(^) (NSArray* objects)) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception{

   NSString* urlString = [self urlFrom:type filter:filter];

    _lastSearchFilter = filter;
    _lastSearchType = type;
    
    if (type == SearchTypeProducts && filter == SearchFilterNone) {
        
        urlString = [NSString stringWithFormat:urlString,
                     [LocationManager shared].defaultLocation.coordinate.latitude,
                     [LocationManager shared].defaultLocation.coordinate.latitude];
        urlString = [NSString stringWithFormat:@"%@%@", [APIv1_0 serverUrl], urlString];
    }else{
        urlString = [NSString stringWithFormat:@"%@%@", [APIv1_0 serverUrl], urlString];
    }
    
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

//! Search with type
- (void)uploadItemWithType:(NSString*)type
                     price:(NSString*)price
                  category:(NSString*)category
                      name:(NSString*)name
                 storeName:(NSString*)storeName
               description:(NSString*)description
                     image:(UIImage*)image
                   success:(void(^) (NSDictionary* object)) success
                   failure:(void(^) (NSError* error, NSString* errorString)) failure
                 exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/products?token=%@&product[name]=%@&product[price]=%@&product[store_name]=%@&product[category]=%@&product[description]=%@&image_name=image.jpg", [APIv1_0 serverUrl], [DataManager shared].api_token, name, price, storeName, category, description];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];

    [request setHTTPMethod:@"POST"];

   // image = [UIImage imageNamed:@"back_but@2x.png"];
    
    NSString *photo64string = [UIImageJPEGRepresentation(image, 0.3) base64EncodedString];
    //NSLog(@"%@", photo64string);
    NSData* imageData = [photo64string dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:imageData];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([value safeObjectForKey:@"errors"] == nil) {
                success(value);
            }else{
                NSString* messageString = [[[value safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:@"base"] safeStringObjectAtIndex:0];
                failure(nil, messageString);
            }
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

//! Search with type
- (void)uploadStoreWithName:(NSString*)name
                     price:(NSString*)price
                  category:(NSString*)category
                      name:(NSString*)name
                 storeName:(NSString*)storeName
               description:(NSString*)description
                     image:(UIImage*)image
                   success:(void(^) (NSDictionary* object)) success
                   failure:(void(^) (NSError* error, NSString* errorString)) failure
                 exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/products?token=%@&product[name]=%@&product[price]=%@&product[store_name]=%@&product[category]=%@&product[description]=%@&image_name=image.jpg", [APIv1_0 serverUrl], [DataManager shared].api_token, name, price, storeName, category, description];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];
    
    // image = [UIImage imageNamed:@"back_but@2x.png"];
    
    NSString *photo64string = [UIImageJPEGRepresentation(image, 0.3) base64EncodedString];
    //NSLog(@"%@", photo64string);
    NSData* imageData = [photo64string dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:imageData];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([value safeObjectForKey:@"errors"] == nil) {
                success(value);
            }else{
                NSString* messageString = [[[value safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:@"base"] safeStringObjectAtIndex:0];
                failure(nil, messageString);
            }
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


#pragma mark - Privat Methods
//! Validate request
- (BOOL)isDataValid:(id)value{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = (NSDictionary*)value;
        if ([[dict objectForKey:@"success"] boolValue] == NO) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}


- (NSString*)urlFrom:(SearchType)type filter:(SearchFilter)filter{
    switch (type) {
        case SearchTypeStores:{
            
            switch (filter) {
                case SearchFilterNone:
                    return @"/stores";
                    break;
                case SearchFilterPopular:
                    return @"/stores/popular";
                    break;
                case SearchFilterNewly:
                    return @"/stores/latest";
                    break;
                case SearchFilterRandom:
                    return @"/stores/random";
                    break;
                case SearchFilterFututrd:
                    return @"/stores/featured";
                    break;
                    
                default:
                    break;
            }
            break;
        }
        
        case SearchTypeProducts:{
            switch (filter) {
                case SearchFilterNone:
                    return @"/products/nearby?lat=%f&lng=%f";
                    break;
                case SearchFilterPopular:
                    return @"/products/popular";
                    break;
                case SearchFilterNewly:
                    return @"/products/latest";
                    break;
                case SearchFilterRandom:
                    return @"/products/random";
                    break;
                case SearchFilterFututrd:
                    return @"/products/featured";
                    break;
                    
                default:
                    break;
            }

            break;
        }
        default:
            break;
    }
}
@end
