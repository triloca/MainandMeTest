//
//  LayoutManager.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/17/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RootNavigationController.h"
#import "AppDelegate.h"
#import "SlidingVC.h"
#import "LeftMenuVC.h"

#import "HomeNVC.h"
#import "HomeVC.h"

#import "ShopCategoryNVC.h"
#import "ShopCategoryVC.h"

#import "PrivacyPolicyVC.h"
#import "PrivacyPolicyNVC.h"

#import "PlacesFollowVC.h"
#import "PlacesFollowNVC.h"

#import "LoginVC.h"


@interface LayoutManager : NSObject

//! App delegate
@property (strong, nonatomic) AppDelegate* appDelegate;

//! Window
@property (strong, nonatomic) UIWindow* window;

//! Main Storyboard
@property (strong, nonatomic) UIStoryboard* mainStoryboard;

//! Root navigation controller
@property (strong, nonatomic) RootNavigationController* rootNVC;

//! Container for modal controller
@property (strong, nonatomic) UIViewController* modalViewController;

//! Sliding VC
@property (strong, nonatomic) SlidingVC* slidingVC;

////////
@property (strong, nonatomic) LeftMenuVC* LeftMenuVC;

@property (strong, nonatomic) HomeNVC* homeNVC;
@property (strong, nonatomic) HomeVC* homeVC;

@property (strong, nonatomic) ShopCategoryNVC* shopCategoryNVC;
@property (strong, nonatomic) ShopCategoryVC* shopCategoryVC;

@property (strong, nonatomic) PrivacyPolicyVC *privacyPolicyVC;
@property (strong, nonatomic) PrivacyPolicyNVC *privacyPolicyNVC;

@property (strong, nonatomic) PlacesFollowVC *placesFollowVC;
@property (strong, nonatomic) PlacesFollowNVC *placesFollowNVC;



+ (LayoutManager*)shared;
+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;


@end