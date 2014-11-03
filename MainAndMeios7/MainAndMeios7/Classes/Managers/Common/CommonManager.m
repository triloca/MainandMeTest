//
//  CommonManager.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/1/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "CommonManager.h"

#define k_USER_ID           @"k_USER_ID"
#define k_API_TOKEN         @"k_API_TOKEN"


@interface CommonManager()

@end


@implementation CommonManager
#pragma mark _______________________ Class Methods _________________________

#pragma mark - Shared Instance and Init
+ (CommonManager *)shared {
    
    static CommonManager *shared = nil;
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
    }
    return self;
}

#pragma mark _______________________ Privat Methods ________________________



#pragma mark _______________________ Delegates _____________________________



#pragma mark _______________________ Public Methods ________________________

#pragma mark User ID
- (NSString*)userId{
   return [[NSUserDefaults standardUserDefaults] stringForKey:k_USER_ID];
}

- (void)setupUserId:(NSString*)userId{
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:k_USER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark API token
- (NSString*)apiToken{
    return [[NSUserDefaults standardUserDefaults] stringForKey:k_API_TOKEN];
}

- (void)setupApiToken:(NSString*)apiToken{
    [[NSUserDefaults standardUserDefaults] setValue:apiToken forKey:k_API_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)isLoggedIn{
    
    if ([self apiToken].length > 0 && [self userId].length > 0) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark _______________________ Notifications _________________________



@end
