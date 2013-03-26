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

//! Upload Product
+ (void)uploadProductWithName:(NSString*)name
                     price:(NSString*)price
                  category:(NSString*)category
                 storeName:(NSString*)storeName
               description:(NSString*)description
                     image:(UIImage*)image
                   success:(void(^) (NSDictionary* object)) success
                   failure:(void(^) (NSError* error, NSString* errorString)) failure
                 exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] uploadProductWithName:name
                                    price:price
                                 category:category
                                storeName:storeName
                              description:description
                                    image:image
                                  success:success
                                  failure:failure
                                exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Upload Product create");
    }
}


//! Upload Store
+ (void)uploadStoreWithName:(NSString*)name
                    country:(NSString*)country
                      state:(NSString*)state
                     street:(NSString*)street
                       city:(NSString*)city
                    zipCode:(NSString*)zipCode
                description:(NSString*)description
                      image:(UIImage*)image
                    success:(void(^) (NSDictionary* object)) success
                    failure:(void(^) (NSError* error, NSString* errorString)) failure
                  exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] uploadStoreWithName:name
                                   country:country
                                     state:state
                                    street:street
                                      city:city
                                   zipCode:zipCode
                               description:description
                                     image:image
                                   success:success
                                   failure:failure
                                 exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Upload Store create");
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

////! Search with type
//- (void)uploadItemWithType:(NSString*)type
//                     price:(NSString*)price
//                  category:(NSString*)category
//                      name:(NSString*)name
//                 storeName:(NSString*)storeName
//               description:(NSString*)description
//                     image:(UIImage*)image
//                   success:(void(^) (NSDictionary* object)) success
//                   failure:(void(^) (NSError* error, NSString* errorString)) failure
//                 exception:(void(^) (NSString* exceptionString))exception{
//    
//    NSString* urlString =
//    [NSString stringWithFormat:@"%@/products/new_create?token=%@&product[name]=%@&product[price]=%@&product[store_name]=%@&product[category]=%@&product[description]=%@&image_name=image.jpg", [APIv1_0 serverUrl], [DataManager shared].api_token, name, price, storeName, category, description];
//    
//    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//    
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
//                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                       timeoutInterval:30];
//
//    [request setHTTPMethod:@"POST"];
//   
//    NSData* imageData = UIImageJPEGRepresentation(image, 0.3);
//    
//   // NSString *photo64string = [imageData base64EncodedString];
//
//    //NSData* imageData = [photo64string dataUsingEncoding:NSUTF8StringEncoding];
//    [request setHTTPBody:imageData];
//    
//    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
//        
//        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        //NSLog(@"%@", returnString);
//        id value = [returnString JSONValue];
//        
//        if ([value isKindOfClass:[NSDictionary class]]) {
//            if ([value safeObjectForKey:@"errors"] == nil) {
//                success(value);
//            }else{
//                NSString* messageString = [[[value safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:@"base"] safeStringObjectAtIndex:0];
//                failure(nil, messageString);
//            }
//        }else{
//            NSString* messageString = @"Server API Error";
//            failure(nil, messageString);
//        }
//        
//    } failure:^(NSURLConnection *connection, NSError *error) {
//        failure(error, error.localizedDescription);
//    } eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
//        exception(exceptionMessage);
//    }];
//    
//    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
//    [connection start];
//    
//}


////! Search with type
//- (void)uploadItemWithType:(NSString*)type
//                     price:(NSString*)price
//                  category:(NSString*)category
//                      name:(NSString*)name
//                 storeName:(NSString*)storeName
//               description:(NSString*)description
//                     image:(UIImage*)image
//                   success:(void(^) (NSDictionary* object)) success
//                   failure:(void(^) (NSError* error, NSString* errorString)) failure
//                 exception:(void(^) (NSString* exceptionString))exception{
//    
//    NSString* urlString =
//    [NSString stringWithFormat:@"%@/products/new_create", [APIv1_0 serverUrl]];
//    
//    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//    
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
//                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                       timeoutInterval:30];
//    
//    [request setHTTPMethod:@"POST"];
//    
//    NSString* bodyString =
//    [NSString stringWithFormat:@"token=%@&product[name]=%@&product[price]=%@&product[store_name]=%@&product[category]=%@&product[description]=%@&product[image]=", [DataManager shared].api_token, name, price, storeName, category, description];
//    
//    NSData* imageData = UIImageJPEGRepresentation(image, 0.3);
//    
//    NSMutableData* bodyData = [NSMutableData data];
//    [bodyData appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
//    [bodyData appendData:imageData];
//    // NSString *photo64string = [imageData base64EncodedString];
//    
//    //NSData* imageData = [photo64string dataUsingEncoding:NSUTF8StringEncoding];
//    [request setHTTPBody:bodyData];
//    
//    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
//        
//        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        //NSLog(@"%@", returnString);
//        id value = [returnString JSONValue];
//        
//        if ([value isKindOfClass:[NSDictionary class]]) {
//            if ([value safeObjectForKey:@"errors"] == nil) {
//                success(value);
//            }else{
//                NSString* messageString = [[[value safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:@"base"] safeStringObjectAtIndex:0];
//                failure(nil, messageString);
//            }
//        }else{
//            NSString* messageString = @"Server API Error";
//            failure(nil, messageString);
//        }
//        
//    } failure:^(NSURLConnection *connection, NSError *error) {
//        failure(error, error.localizedDescription);
//    } eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
//        exception(exceptionMessage);
//    }];
//    
//    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
//    [connection start];
//    
//}

//! Upload Product
- (void)uploadProductWithName:(NSString*)name
                        price:(NSString*)price
                     category:(NSString*)category
                    storeName:(NSString*)storeName
                  description:(NSString*)description
                        image:(UIImage*)image
                      success:(void(^) (NSDictionary* object)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/products/new_create", [APIv1_0 serverUrl]];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];
    
    NSData* imageData = UIImageJPEGRepresentation(image, 0.3);
    
    NSString *boundary = @"------WebKitFormBoundary4QuqLuM1cE5lMwCy";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    //Populate a dictionary with all the regular values you would like to send.
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:11];
    [parameters setValue:[DataManager shared].api_token forKey:@"token"];
    if (name.length > 0) {
        [parameters setValue:name forKey:@"product[name]"];
    }
    if (price.length > 0) {
        [parameters setValue:price forKey:@"product[price]"];
    }
    if (storeName.length > 0) {
        [parameters setValue:storeName forKey:@"product[store_name]"];
    }
    if (category.length > 0) {
        [parameters setValue:category forKey:@"product[category]"];
    }
    if (description.length > 0) {
        [parameters setValue:description forKey:@"product[description]"];
    }
    
    // add params (all params are strings)
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *FileParamConstant = @"product[image]";
    
    //Assuming data is not nil we add this to the multipart form
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //Close off the request with the boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the request
    [request setHTTPBody:body];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([value safeObjectForKey:@"errors"] == nil) {
                success(value);
            }else{
                NSString* key = [[[value safeDictionaryObjectForKey:@"errors"] allKeys] safeStringObjectAtIndex:0];
                NSString* message = [[[value safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:key] safeStringObjectAtIndex:0];
                NSString* messageString = [NSString stringWithFormat:@"%@ %@", key, message];
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


//! Upload Store
- (void)uploadStoreWithName:(NSString*)name
                        country:(NSString*)country
                     state:(NSString*)state
                    street:(NSString*)street
                     city:(NSString*)city
                    zipCode:(NSString*)zipCode
                  description:(NSString*)description
                        image:(UIImage*)image
                      success:(void(^) (NSDictionary* object)) success
                      failure:(void(^) (NSError* error, NSString* errorString)) failure
                    exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/stores", [APIv1_0 serverUrl]];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];
    
    NSData* imageData = UIImageJPEGRepresentation(image, 0.3);
    
    NSString *boundary = @"------WebKitFormBoundary4QuqLuM1cE5lMwCy";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    //Populate a dictionary with all the regular values you would like to send.
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:11];
    [parameters setValue:[DataManager shared].api_token forKey:@"token"];
    if (name.length > 0) {
        [parameters setValue:name forKey:@"store[name]"];
    }
    if (street.length > 0) {
        [parameters setValue:street forKey:@"store[street]"];
    }
    if (city.length > 0) {
        [parameters setValue:city forKey:@"store[city]"];
    }
    if (state.length > 0) {
        [parameters setValue:state forKey:@"store[state]"];
    }
    if (zipCode.length > 0) {
        [parameters setValue:zipCode forKey:@"store[postal_code]"];
    }
    if (country.length > 0) {
        [parameters setValue:country forKey:@"store[country]"];
    }
    if (description.length > 0) {
        [parameters setValue:description forKey:@"store[description]"];
    }
    
    // add params (all params are strings)
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *FileParamConstant = @"store[image]";
    
    //Assuming data is not nil we add this to the multipart form
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //Close off the request with the boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the request
    [request setHTTPBody:body];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([value safeObjectForKey:@"errors"] == nil) {
                success(value);
            }else{
                
                NSString* key = [[[value safeDictionaryObjectForKey:@"errors"] allKeys] safeStringObjectAtIndex:0];
                NSString* message = [[[value safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:key] safeStringObjectAtIndex:0];
                NSString* messageString = [NSString stringWithFormat:@"%@ %@", key, message];
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
