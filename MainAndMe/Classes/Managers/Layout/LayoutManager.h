//
//  LayoutManager.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "RootViewController.h"

@interface LayoutManager : NSObject

@property (assign, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic) MainViewController* mainViewController;
@property (strong, nonatomic) UINavigationController* rootNavigationController;
@property (strong, nonatomic) RootViewController* rootTabBarController;

+ (LayoutManager*)shared;
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)showLogin;
@end