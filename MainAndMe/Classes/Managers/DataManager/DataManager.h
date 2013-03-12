//
//  DataManager.h
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface DataManager : NSObject

@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* api_token;

+ (DataManager*)shared;

@end