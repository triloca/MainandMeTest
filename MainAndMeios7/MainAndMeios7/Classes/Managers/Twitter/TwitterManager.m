//
//  TwitterManager.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/21/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "TwitterManager.h"

#define kTwitterOAuthConsumerKey		@"CGLJ4SdxPBnJG4ygNsAs1Q"
#define kTwitterOAuthConsumerSecret	    @"CBSHV5bsvSO2tr17tCr1xreEwTbV8WoO6nwBfyGSsUM"

@interface TwitterManager() <FHSTwitterEngineAccessTokenDelegate>

@end


@implementation TwitterManager
#pragma mark _______________________ Class Methods _________________________

#pragma mark - Shared Instance and Init
+ (TwitterManager *)shared {
    
    static TwitterManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

#pragma mark ____________________________ Init _____________________________

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
        [self setupKeys];
    }
    return self;
}

#pragma mark _______________________ Privat Methods ________________________

- (void)setupKeys{
   
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:kTwitterOAuthConsumerKey
                                                    andSecret:kTwitterOAuthConsumerSecret];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
}

#pragma mark _______________________ Delegates _____________________________

- (NSString *)loadAccessToken{
    return nil;
}
- (void)storeAccessToken:(NSString *)accessToken{

}


- (void)twitterEngineControllerDidCancel{

}

#pragma mark _______________________ Public Methods ________________________


- (void)loginVCPresentation:(void (^)(UIViewController* twitterLoginVC))presentation
                    success:(void (^)(UIViewController* twitterLoginVC, FHSToken* token))success
                    failure:(void (^)(UIViewController* twitterLoginVC, NSError* error))failure
                    cancel:(void (^)(UIViewController* twitterLoginVC))cancel
            alreadyLoggedIn:(void (^)(UIViewController* twitterLoginVC, FHSToken* token))alreadyLoggedIn{
    
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL isSuccess) {
        
        NSLog(isSuccess ? @"Twitter login success" : @"Twitter login failed");
        
        if (isSuccess) {
            success(loginController, [FHSTwitterEngine sharedEngine].accessToken);
        }else{
            failure(loginController, nil);
        }
        
    }];

    
    if (loginController) {
        presentation(loginController);
    }else{
        alreadyLoggedIn(loginController, [FHSTwitterEngine sharedEngine].accessToken);
    }
    
}


- (void)logout{
    [[FHSTwitterEngine sharedEngine] logout];
}

#pragma mark _______________________ Notifications _________________________



@end
