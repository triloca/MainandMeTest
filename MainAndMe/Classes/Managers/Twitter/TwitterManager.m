//
//  TwitterManager.m
//  POGO
//
//  Created by Alexander Bukov on 10/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwitterManager.h"
#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "UserDefaultsManager.h"
#import "NSURLConnectionDelegateHandler.h"
#import "AFNetworking.h"

#define kTwitterOAuthConsumerKey		@"CGLJ4SdxPBnJG4ygNsAs1Q"
#define kTwitterOAuthConsumerSecret	    @"CBSHV5bsvSO2tr17tCr1xreEwTbV8WoO6nwBfyGSsUM"

typedef void (^SuccessBlock)(TwitterManager* facebookManager);
typedef void (^FailureBlock)(TwitterManager* facebookManager, NSError* error);

@interface TwitterManager()
<SA_OAuthTwitterControllerDelegate,
SA_OAuthTwitterEngineDelegate, MGTwitterEngineDelegate>

@property (copy, nonatomic) SuccessBlock successBlock;
@property (copy, nonatomic) FailureBlock failureBlock;

@property (copy, nonatomic) SuccessBlock requestSuccessBlock;
@property (copy, nonatomic) FailureBlock requestFailureBlock;

@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) SA_OAuthTwitterEngine* twitter;

@property (strong, nonatomic) NSArray* followersIDArray;
@property (strong, nonatomic) NSMutableArray* followersArray;
@property (assign, nonatomic) NSInteger followersRequestCount;

@property (strong, nonatomic) NSString* currentUserID;
@end


@implementation TwitterManager

#pragma mark - Shared Instance and Init
+ (TwitterManager *)sharedInstance {
    
    static TwitterManager *shared = nil;
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
        _isLoading = NO;
        self.twitter = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
        _twitter.consumerKey = kTwitterOAuthConsumerKey;
        _twitter.consumerSecret = kTwitterOAuthConsumerSecret;
        _followersArray = [NSMutableArray new];
    }
    return self;
}


+ (void)loadTinyUrlForUrl:(NSString*) url
                  success:(void(^) (NSString* tinyUrl)) success
                  failure:(void(^) (NSError* error, NSString* errorString)) failure
                exception:(void(^) (NSString* exceptionString))exception{
    @try {
        [[self sharedInstance] loadTinyUrlForUrl:url
                                         success:success
                                         failure:failure
                                       exception:exception];
    }
    @catch (NSException *exc) {
        exception(@"Exeption\n Load TinyUrl create");
    }

}

- (UIViewController*)oAuthTwitterController{
    
    UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_twitter delegate: self];
    if (controller)
    {
        return controller;
    }
    else
    {
        [_twitter sendUpdate: [NSString stringWithFormat: @"twitter: %@", [NSDate date]]];
        return nil;
    }
}



#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username
{
    NSLog(@"user-%@ , data - %@", username, data);
    [[UserDefaultsManager shared] saveTwitterAuthData:data forUsername:username];

    NSString* userId = @"";
    NSString* authtoken = @"";
    
    NSArray *firstSplit = [data componentsSeparatedByString:@"&"];
    NSArray *secondSplit = [[firstSplit safeStringObjectAtIndex:2] componentsSeparatedByString:@"="];

    NSArray *authSplit = [[firstSplit safeStringObjectAtIndex:0] componentsSeparatedByString:@"="];
    authtoken = [authSplit safeStringObjectAtIndex:1];
    userId = [secondSplit safeStringObjectAtIndex:1];

    [[UserDefaultsManager shared] saveTwitterLogin:username
                                         authToken:authtoken
                                            userId:userId
                                             email:@""];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	_currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey: @"currentUserTwitterID"];
    return [[UserDefaultsManager shared] twitterAuthDataForUsername:username];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username
{
	NSLog(@"Authenicated for %@", username);
    if (_successBlock) {
        _successBlock(self);
    }
    //[_twitter getUserInformationFor:username];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller
{
	NSLog(@"Authentication Failed!");
    if (_failureBlock) {
        _failureBlock(self, nil);
    }
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller
{
	NSLog(@"Authentication Canceled.");
    if (_failureBlock) {
        _failureBlock(self, nil);
    }
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier
{
    
    NSDictionary* result = nil;
    if ([userInfo isKindOfClass:[NSArray class]] && [userInfo count] > 0)
    {
        result = [userInfo objectAtIndex:0];
        if ([result isKindOfClass:[NSDictionary class]]) {
            _currentUserID = [result objectForKey:@"id"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_currentUserID forKey: @"currentUserTwitterID"];
            [defaults synchronize];

        }
        //VLFLog(@"%@", result);
    }
       
}

- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier{

}



- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier{

}
- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier{
    if (_requestSuccessBlock) {
        _requestSuccessBlock(self);
    }
}
- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier{

}

- (void)searchResultsReceived:(NSArray *)searchResults forRequest:(NSString *)connectionIdentifier{

}



//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier
{
    if (_requestSuccessBlock) {
        _requestSuccessBlock(self);
    }
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error
{
    if (_requestFailureBlock) {
        _requestFailureBlock(self, error);
    }
}


#pragma mark - Privat Methods

- (BOOL)isAuthorized{
   return [_twitter isAuthorized];
}

- (void)setLoginSuccess:(void(^)(TwitterManager* facebookManager))successBlock
                failure:(void (^)(TwitterManager* facebookManager, NSError* error))failureBlock{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
}

- (void)logout{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _currentUserID = @"";

    [[UserDefaultsManager shared] clearTwitterAuthData];
    [defaults removeObjectForKey:@"currentUserTwitterID"];
    [defaults synchronize];
    
    [_twitter setClearsCookies:YES];
    [_twitter clearAccessToken];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"twitter"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}


- (void)loadFollowersSuccess:(void (^)(TwitterManager *))successBlock
                     failure:(void (^)(TwitterManager *, NSError *))failureBlock{
    if (_currentUserID == nil) {
        _currentUserID = @"";
    }
    
    NSString* urlString = [NSString stringWithFormat:@"https://api.twitter.com/1/followers/ids.json?cursor=-1&user_id=%@", _currentUserID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
                                             NSLog(@"Tweets: %@", [json valueForKeyPath:@"ids"]);
                                             if ([[json objectForKey:@"ids"] isKindOfClass:[NSArray class]]) {
                                                 _followersIDArray = [json objectForKey:@"ids"];
                                                 [self loadFollowersDetailsSuccess:successBlock
                                                                           failure:failureBlock];
                                             }
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
                                         
                                             NSLog(@"Error : %@", [error description]);
                                             if (failureBlock) {
                                                 failureBlock(self, error);
                                             }
                                         }];
    
       [operation start];
}

- (void)loadFollowersDetailsSuccess:(void (^)(TwitterManager *))successBlock
                            failure:(void (^)(TwitterManager *, NSError *))failureBlock{
    
    _followersArray = [NSMutableArray new];
    _followersRequestCount = [_followersIDArray count];
    
    if (_followersRequestCount == 0) {
        if (_requestSuccessBlock) {
            _requestSuccessBlock(self);
        }
    }
    
    for (NSString* idString in _followersIDArray) {
        
        NSString* urlString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?user_id=%@&include_entities=true", idString];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                             JSONRequestOperationWithRequest:request
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
                                                
                                                 NSMutableDictionary* follower = [NSMutableDictionary new];
                                                 [follower safeSetObject:[json objectForKey:@"id"] forKey:@"id"];
                                                 [follower safeSetObject:[json objectForKey:@"name"] forKey:@"name"];
                                                 [follower safeSetObject:[json objectForKey:@"profile_image_url"] forKey:@"profile_image_url"];
                                                 [_followersArray safeAddObject:[NSDictionary dictionaryWithDictionary:follower]];
                                                 _followersRequestCount--;
                                                 
                                                 if (_followersRequestCount == 0) {
                                                     if (successBlock) {
                                                         successBlock(self);
                                                     }
                                                 }
                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
                                                 NSLog(@"Error : %@", [error description]);
                                                
                                                 _followersRequestCount--;
                                                 if (_followersRequestCount == 0) {
                                                     if (successBlock) {
                                                         successBlock(self);
                                                     }
                                                 }
                                             }];
        [operation start];
    }
}

- (NSArray*)followersArray{
    return [NSArray arrayWithArray:_followersArray];
}
//https://api.twitter.com/1.1/direct_messages/new.json

- (void)postMessage:(NSString*)idString
            success:(void (^)(TwitterManager *))successBlock
            failure:(void (^)(TwitterManager *, NSError *))failureBlock{
    self.requestSuccessBlock = successBlock;
    self.requestFailureBlock = failureBlock;
    [_twitter sendDirectMessage:@"Wellcome to Main And Me" to:idString];
    
//    if (idString == nil) {
//        idString = @"";
//    }
//    
//    NSString* urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/direct_messages/new.json"];
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:url];
//    [request setHTTPMethod:@"POST"];
//    
//    NSMutableData *body = [NSMutableData data];
//    
//    [body appendData:[[NSString stringWithFormat:@"text=%@&user_id=%@",
//                       @"testtewitter",
//                       idString]
//                      dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [request setHTTPBody:body];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
//    
//    [operation start];
}


- (void)sendUpdate:(NSString*)text
           success:(void (^)(TwitterManager *))successBlock
           failure:(void (^)(TwitterManager *, NSError *))failureBlock
         exception:(void (^) (NSString* exceptionString))exception{
    @try {
        self.requestSuccessBlock = successBlock;
        self.requestFailureBlock = failureBlock;
        [_twitter sendUpdate:text];
    }
    @catch (NSException *exce) {
        exception(@"Exeption\n Send Update create");
    }
   
   
}

- (void)loadTinyUrlForUrl:(NSString*) url
                     success:(void(^) (NSString* tinyUrl)) success
                     failure:(void(^) (NSError* error, NSString* errorString)) failure
                   exception:(void(^) (NSString* exceptionString))exception{
    
    NSString* urlString =
    [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@", url];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
    
        if ([returnString isKindOfClass:[NSString class]]) {
            success(returnString);
        }else{
            failure(nil, @"Server Error");
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
