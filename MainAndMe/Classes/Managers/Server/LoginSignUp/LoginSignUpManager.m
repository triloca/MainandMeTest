//
//  LoginSignUpManager.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "LoginSignUpManager.h"
#import "APIv1_0.h"
#import "NSURLConnectionDelegateHandler.h"
#import "JSON.h"
#import "UserDefaultsManager.h"


@interface LoginSignUpManager()
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* accessToken;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* authtoken;
@end


@implementation LoginSignUpManager

#pragma mark - Shared Instance and Init
+ (LoginSignUpManager *)shared {
    
    static LoginSignUpManager *shared = nil;
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

#pragma mark - SignUp request
//! SignUp request

+ (void)signUpWithEmail:(NSString*)email
               password:(NSString*)password
               userName:(NSString*)userName
                success:(void(^) (NSString* token, NSString* email)) success
                failure:(void(^) (NSError* error, NSString* errorString)) failure
              exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] signUpWithEmail:email
                          password:password
                          userName:userName
                           success:success
                           failure:failure
                         exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n SingUp create");
    }
    
}


- (void)signUpWithEmail:(NSString*)email
               password:(NSString*)password
               userName:(NSString*)userName
                success:(void(^) (NSString* token, NSString* email)) success
                failure:(void(^) (NSError* error, NSString* errorString)) failure
              exception:(void(^) (NSString* exceptionString))exception

{
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users?user[email]=%@&user[name]=%@&user[password]=%@&user[password_confirmation]=%@&user[terms]=1", [APIv1_0 serverUrl], email, userName, password, password];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    //[[NSArray array] objectAtIndex:5]; //! To test exception
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isDataValid:value]) {
            NSString* token = [[value safeDictionaryObjectForKey:@"user"] safeStringObjectForKey:@"api_token"];
            NSString* email = [[value safeDictionaryObjectForKey:@"user"] safeStringObjectForKey:@"email"];
            success(token, email);
        }else{
            NSString* messageString = @"";
            NSArray* messagesValues = [value allValues];
            NSArray* messageKeys = [value allKeys];
            NSString* valueString = @"";
            NSString* keyString = @"";
            
            if ([messagesValues count] > 0) {
                NSArray* message = [messagesValues safeArrayObjectAtIndex:0];
                valueString = [message safeStringObjectAtIndex:0];
            }
            
            if ([messageKeys count] > 0) {
                keyString = [messageKeys safeStringObjectAtIndex:0];
            }
            
            messageString = [NSString stringWithFormat:@"%@ %@", keyString, valueString];
            
            if (messageString.length > 1){
                failure(nil, messageString);
            }else{
                failure(nil, @"Invalid information");
            }
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        failure(error, error.localizedDescription);
    } eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        exception(exceptionMessage);
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
}

//! Login request
-(void)loginWithEmail:(NSString*)email
             password:(NSString*)password
              success:(void(^) (NSDictionary* user)) success
              failure:(void(^) (NSError* error, NSString* errorString)) failure
            exception:(void(^) (NSString* exceptionString))exception{
    
    self.email = email;
    self.password = password;
    self.userId = nil;
    self.accessToken = nil;
    self.username = nil;
    self.authtoken = nil;
    
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users/sign_in?[user_login][password]=%@&[user_login][email]=%@", [APIv1_0 serverUrl], password, email];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isDataValid:value]) {
            
            [[UserDefaultsManager shared] saveStandardLogin:_email
                                                   password:_password];
            
            NSDictionary* user = [value safeDictionaryObjectForKey:@"user"];
            success(user);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"message"];
            
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


@end
