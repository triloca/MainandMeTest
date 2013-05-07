//
//  SettingsManager.m
//  MainAndMe
//
//  Created by Sasha on 3/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SettingsManager.h"
#import "DataManager.h"
#import "APIv1_0.h"
#import "JSON.h"
#import "NSURLConnectionDelegateHandler.h"



@interface SettingsManager()

@end


@implementation SettingsManager

#pragma mark - Shared Instance and Init
+ (SettingsManager *)shared {
    
    static SettingsManager *shared = nil;
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
    }
    return self;
}


//! Load Current User
+ (void)loadCurrentUserWithSuccess:(void(^) (NSDictionary* profile)) success
                           failure:(void(^) (NSError* error, NSString* errorString)) failure
                         exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self shared] loadCurrentUserWithSuccess:success
                                          failure:failure
                                        exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load Current User create");
    }
}


//! Update Current User
+ (void)saveCurrentUserWithName:(NSString*)username
                       password:(NSString*)password
                       birthday:(NSString*)birthday
                        address:(NSString*)address
                   phone_number:(NSString*)phone_number
              email_communities:(BOOL)email_communities
                   email_stores:(BOOL)email_stores
                   email_people:(BOOL)email_people
                       wishlist:(BOOL)wishlist
                        success:(void(^) (NSDictionary* profile)) success
                        failure:(void(^) (NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] saveCurrentUserWithName:username
                                      password:password
                                      birthday:birthday
                                       address:address
                                  phone_number:phone_number
                             email_communities:email_communities
                                  email_stores:email_stores
                                  email_people:email_people
                                      wishlist:wishlist
                                       success:success
                                       failure:failure
                                     exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Update User create");
    }
}

#pragma mark - 
//! Load Current User
- (void)loadCurrentUserWithSuccess:(void(^) (NSDictionary* profile)) success
                           failure:(void(^) (NSError* error, NSString* errorString)) failure
                         exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users/current?_token=%@", [APIv1_0 serverUrl], [DataManager shared].api_token];
    
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

//! Update Current User
- (void)saveCurrentUserWithName:(NSString*)username
                       password:(NSString*)password
                       birthday:(NSString*)birthday
                        address:(NSString*)address
                   phone_number:(NSString*)phone_number
              email_communities:(BOOL)email_communities
                   email_stores:(BOOL)email_stores
                   email_people:(BOOL)email_people
                       wishlist:(BOOL)wishlist
                        success:(void(^) (NSDictionary* profile)) success
                        failure:(void(^) (NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users/%@?_token=%@&id=%@&user[name]=%@&user[password]=%@&user[password_confirmation]=%@&user[date_of_birth]=%@&user[address]=%@&user[phone_number]=%@&user[setting_attributes][email_communities]=%@&user[setting_attributes][email_stores]=%@&user[setting_attributes][email_people]=%@&user[setting_attributes][wishlist]=%@", [APIv1_0 serverUrl],
     [DataManager shared].userId,
     [DataManager shared].api_token,
     [DataManager shared].userId,
     username,
     password,
     password,
     birthday,
     address,
     phone_number,
     [NSString stringWithFormat:@"%d", email_communities],
     [NSString stringWithFormat:@"%d", email_stores],
     [NSString stringWithFormat:@"%d", email_people],
     [NSString stringWithFormat:@"%d", wishlist]];
    
    //_token=%@&id=%@&user[name]=%@&user[password]=%@&user[password_confirmation]=%@&user[date_of_birth]=%@&user[address]=%@&user[phone_number]=%@&user[setting_attributes][email_communities]=%@&user[setting_attributes][email_stores]=%@&user[setting_attributes][email_people]=%@&user[setting_attributes][wishlist]=%@
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"PUT"];
    
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


@end
