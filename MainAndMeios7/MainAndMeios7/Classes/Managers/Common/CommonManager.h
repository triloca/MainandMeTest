//
//  CommonManager.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/1/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//


@interface CommonManager : NSObject

+ (CommonManager*)shared;

#pragma mark User ID
- (NSString*)userId;
- (void)setupUserId:(NSString*)userId;

#pragma mark API token
- (NSString*)apiToken;
- (void)setupApiToken:(NSString*)apiToken;

#pragma mark Is logged
- (BOOL)isLoggedIn;

@end