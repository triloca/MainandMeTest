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
#import "DataManager.h"
#import "TwitterManager.h"


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

//! Login via social request
+ (void)loginViaSocialWithUserId:(NSString*)userId
                     accessToken:(NSString*)accessToken
                       authtoken:(NSString*)authtoken
                           email:(NSString*)email
                        username:(NSString*)username
                            type:(NSString*)type
                         success:(void(^) (NSString* userId, NSString* api_token)) success
                         failure:(void(^) (NSError* error, NSString* errorString)) failure
                       exception:(void(^) (NSString* exceptionString))exception{

    
    @try {
        [[self shared] loginViaSocialWithUserId:userId
                                    accessToken:accessToken
                                      authtoken:authtoken
                                          email:email
                                       username:username
                                           type:type
                                        success:success
                                        failure:failure
                                      exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Login Via Social create");
    }
}

//! Login request
+ (void)loginWithEmail:(NSString*)email
              password:(NSString*)password
               success:(void(^) (NSDictionary* user)) success
               failure:(void(^) (NSError* error, NSString* errorString)) failure
             exception:(void(^) (NSString* exceptionString))exception{

    @try {
        [[self shared] loginWithEmail:email
                             password:password
                              success:success
                              failure:failure
                            exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Login With Email create");
    }

}

+ (void)forgotPasswordForEmail:(NSString*)email
                       success:(void(^)()) success
                       failure:(void(^) (NSError* error, NSString* errorString)) failure
                     exception:(void(^) (NSString* exceptionString))exception{
   
   
    @try {
          [[self shared] forgotPasswordForEmail:email
                                  success:success
                                  failure:failure
                                exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Forgot Password Email create");
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
- (void)loginWithEmail:(NSString*)email
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
            NSString* userId = [NSString stringWithFormat:@"%d", [[user valueForKeyPath:@"id"] intValue]];
            NSString* token = [user safeStringObjectForKey:@"api_token"];
            [DataManager shared].userId = userId;
            [DataManager shared].api_token = token;
            
            [[UserDefaultsManager shared] saveReturnedUsername:[user safeStringObjectForKey:@"name"]];

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

- (void)forgotPasswordForEmail:(NSString*)email
                       success:(void(^)()) success
                       failure:(void(^) (NSError* error, NSString* errorString)) failure
                     exception:(void(^) (NSString* exceptionString))exception{

    self.email = nil;
    self.password = nil;
    self.userId = nil;
    self.accessToken = nil;
    self.username = nil;
    self.authtoken = nil;
    
    
    NSString* urlString =
    [NSString stringWithFormat:@"%@/users/send_reset_password_token?email=%@", [APIv1_0 serverUrl], email];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isValidPasswordReset:value]) {
            success();
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

//! Login via social request
-(void)loginViaSocialWithUserId:(NSString*)userId
                    accessToken:(NSString*)accessToken
                      authtoken:(NSString*)authtoken
                          email:(NSString*)email
                       username:(NSString*)username
                           type:(NSString*)type
                        success:(void(^) (NSString* userId, NSString* api_token)) success
                        failure:(void(^) (NSError* error, NSString* errorString)) failure
                      exception:(void(^) (NSString* exceptionString))exception{
    
    
    self.userId = userId;
    self.accessToken = accessToken;
    self.authtoken = authtoken;
    self.email = email;
    self.username = username;
    self.password = nil;
    
    if (_email == nil || [_email isEqualToString:@"null"]) {
        _email = @"";
    }
    
    NSString* urlString = @"";
    if ([type isEqualToString:@"facebook"]) {
        urlString =
        [NSString stringWithFormat:@"%@/authenticae/create?omniauth[uid]=%@&omniauth[provider]=%@&omniauth[credentials][token]=%@&omniauth[credentials][secret]=&omniauth[info][email]=%@&omniauth[info][name]=%@&omniauth[info][image]=&omniauth[info][terms]=%@", [APIv1_0 serverUrl], userId, type, accessToken, email, username, @"1"];
        
    }else if ([type isEqualToString:@"twitter"]) {
        urlString =
        [NSString stringWithFormat:@"%@/authenticae/create?omniauth[uid]=%@&omniauth[provider]=%@&omniauth[credentials][token]=%@&omniauth[credentials][secret]=&omniauth[info][email]=%@&omniauth[info][name]=%@&omniauth[info][image]=&omniauth[info][terms]=%@", [APIv1_0 serverUrl], userId, type, authtoken, email, username, @"1"];
    }
    
    NSLog(@"urlString = %@", urlString);
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"urlString = %@", urlString);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        if ([self isDataValid:value]) {
            
            if ([type isEqualToString:@"facebook"]) {
                [[UserDefaultsManager shared] saveFacebookLogin:_userId
                                                       userName:_username
                                                    accessToken:_accessToken
                                                          email:_email];
            }else {
                [[UserDefaultsManager shared] saveTwitterLogin:_username
                                                     authToken:_authtoken
                                                        userId:_userId
                                                         email:_email];
            }
            
            NSDictionary* user = [value safeDictionaryObjectForKey:@"user"];
            NSString* userId = [NSString stringWithFormat:@"%d", [[user valueForKeyPath:@"id"] intValue]];
            NSString* token = [user safeStringObjectForKey:@"api_token"];
            [DataManager shared].userId = userId;
            [DataManager shared].api_token = token;
            
            success(userId, token);
        }else{
            NSString* messageString = [value safeStringObjectForKey:@"message"];
            messageString = [NSString stringWithFormat:@"%@ %@", messageString, @"Server API Error!"];
            failure(nil, messageString);
        }
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        [[UserDefaultsManager shared] clearOldLoginSettings];
        failure(error, error.localizedDescription);
    } eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        [[UserDefaultsManager shared] clearOldLoginSettings];
        exception(exceptionMessage);
    }];

    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
}


////! Logout request
//-(void)logoutWithSuccess:(void(^) (NSDictionary* user)) success
//                 failure:(void(^) (NSError* error, NSString* errorString)) failure
//               exception:(void(^) (NSString* exceptionString))exception{
//    
//    self.email = nil;
//    self.password = nil;
//    self.userId = nil;
//    self.accessToken = nil;
//    self.username = nil;
//    self.authtoken = nil;
//    
//    
//    NSString* urlString =
//    [NSString stringWithFormat:@"%@/users/sign_in?[user_login][password]=%@&[user_login][email]=%@", [APIv1_0 serverUrl], password, email];
//    
//    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//    
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
//                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                       timeoutInterval:20];
//    [request setHTTPMethod:@"POST"];
//    
//    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
//        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", returnString);
//        id value = [returnString JSONValue];
//        if ([self isDataValid:value]) {
//            
//            [[UserDefaultsManager shared] saveStandardLogin:_email
//                                                   password:_password];
//            
//            NSDictionary* user = [value safeDictionaryObjectForKey:@"user"];
//            success(user);
//        }else{
//            NSString* messageString = [value safeStringObjectForKey:@"message"];
//            
//            failure(nil, messageString);
//        }
//        
//    } failure:^(NSURLConnection *connection, NSError *error) {
//        failure(error, error.localizedDescription);
//    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
//        exception(exceptionMessage);
//    }];
//    
//    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
//    [connection start];
//}


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


//! Validate request
- (BOOL)isValidPasswordReset:(id)value{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = (NSDictionary*)value;
        if ([[dict safeStringObjectForKey:@"message"] isEqualToString:@"OK"]) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}



- (void)saveDefoultsForLogin{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (_email) {
        [userDefaults setObject:_email forKey:kUserEmail];
    }else{
        [userDefaults removeObjectForKey:kUserEmail];
    }
    
    if (_password) {
        [userDefaults setObject:_password forKey:kUserPassword];
    }else{
        [userDefaults removeObjectForKey:kUserPassword];
    }
    
    if (_userId) {
        [userDefaults setObject:_userId forKey:kUserId];
    }else{
        [userDefaults removeObjectForKey:kUserId];
    }
    if (_accessToken) {
        [userDefaults setObject:_accessToken forKey:kUserAccessToken];
    }else{
        [userDefaults removeObjectForKey:kUserAccessToken];
    }
    if (_username) {
        [userDefaults setObject:_username forKey:kUsername];
    }else{
        [userDefaults removeObjectForKey:kUsername];
    }
    if (_authtoken) {
        [userDefaults setObject:_username forKey:kUserAuthtoken];
    }else{
        [userDefaults removeObjectForKey:kUserAuthtoken];
    }
    
    
    //[userDefaults removeObjectForKey:kLoginType]; //! For testing only
    [userDefaults synchronize];
}


- (void)logout{
    
    self.email = nil;
    self.password = nil;
    self.userId = nil;
    self.accessToken = nil;
    self.username = nil;
    self.authtoken = nil;
    
    [FBSession.activeSession closeAndClearTokenInformation];
    [[TwitterManager sharedInstance] logout];
    [[DataManager shared] clearUserInfo];
    [[UserDefaultsManager shared] clearOldLoginSettings];
}

@end
