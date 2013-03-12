//
//  LayoutManager.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@interface LayoutManager : NSObject

@property (assign, nonatomic) AppDelegate* appDelegate;

+ (LayoutManager*)shared;
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
@end