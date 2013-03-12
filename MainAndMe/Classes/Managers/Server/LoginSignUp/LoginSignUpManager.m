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


@interface LoginSignUpManager()

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
        exception(@"Exeption, SingUp create");
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
                NSArray* message = [messagesValues objectAtIndex:0];
                if ([message count] > 0) {
                    valueString = [message objectAtIndex:0];
                }
            }
            
            if ([messageKeys count] > 0) {
                keyString = [messageKeys objectAtIndex:0];
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
