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
              success:(void(^) (NSString* name)) success
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

#pragma mark - 
//! Load place info
-(void)loadPlaceInfo:(CGFloat)latnear
             lngnear:(CGFloat)lngnear
              success:(void(^) (NSString* name)) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception{
    
        
//    CLGeocoder* geoCoder = [CLGeocoder new];
//    CLLocation* location = [[CLLocation alloc] initWithLatitude:latnear
//                                                      longitude:lngnear];
                          
//    [geoCoder reverseGeocodeLocation:location
//                   completionHandler:^(NSArray *placemarks, NSError *error) {
//         
//         CLPlacemark *placemark = [placemarks objectAtIndex:0];
//         
//         NSDictionary* addressDictionary = placemark.addressDictionary;
//         
//         [addressDictionary safeStringObjectForKey:@"Name"];
//     }];
    
 
    
    //"http://ws.geonames.org/findNearbyPostalCodes?lat=%f&lng=%f"
    NSString* urlString =
    [NSString stringWithFormat:@"http://ws.geonames.org/findNearbyPostalCodesJSON?lat=%f&lng=%f", latnear, lngnear];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        NSArray* postalCodes = [value safeArrayObjectForKey:@"postalCodes"];
        NSDictionary* postalCode = [postalCodes safeDictionaryObjectAtIndex:0];
        NSString* adminName1 = [postalCode safeStringObjectForKey:@"adminName1"];
        
        success(adminName1);
        
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

   
    //[[NSArray new] objectAtIndex:5]; to test exception
   NSString* urlString = [self urlFrom:type filter:filter];

    _lastSearchFilter = filter;
    _lastSearchType = type;
    
    if (type == SearchTypeProducts && filter == SearchFilterNone) {
        
        urlString = [NSString stringWithFormat:urlString, 42.313, -72.63];//?
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
        
      
        //[[NSArray new] objectAtIndex:5]; //to test exception
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
