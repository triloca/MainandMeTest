//
//  LayoutManager.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/17/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RootNavigationController.h"
#import "AppDelegate.h"

@interface LayoutManager : NSObject

//! App delegate
@property (strong, nonatomic) AppDelegate* appDelegate;

//! Window
@property (strong, nonatomic) UIWindow* window;

//! Main Storyboard
@property (strong, nonatomic) UIStoryboard* mainStoryboard;

//! Root navigation controller
@property (strong, nonatomic) RootNavigationController* rootNVC;


+ (LayoutManager*)shared;
+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end