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

#import "SearchNVC.h"
#import "SearchVC.h"

#import "AboutNVC.h"
#import "AboutVC.h"

#import "BaseNavigationController.h"
#import "StoresByNameVC.h"

#import "MyWishlistVC.h"

#import "NotificationsVC.h"

#import "PeopleFollowNVC.h"
#import "PeopleFollowVC.h"

#import "ProfileNVC.h"
#import "ProfileVC.h"

#import "SpecialNVC.h"
#import "SpecialVC.h"

#import "LoginVC.h"

#import "ProximityKitManager.h"


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

@property (strong, nonatomic) BaseNavigationController *storesByNameNVC;
@property (strong, nonatomic) StoresByNameVC *storesByNameVC;

@property (strong, nonatomic) BaseNavigationController *myWishlistNVC;
@property (strong, nonatomic) MyWishlistVC *myWishlistVC;

@property (strong, nonatomic) BaseNavigationController *notificationsNVC;
@property (strong, nonatomic) NotificationsVC *notificationsVC;

@property (strong, nonatomic) ProfileNVC *profileNVC;
@property (strong, nonatomic) ProfileVC *profileVC;

@property (strong, nonatomic) ShopCategoryNVC* shopCategoryNVC;
@property (strong, nonatomic) ShopCategoryVC* shopCategoryVC;

@property (strong, nonatomic) SearchNVC* searchNVC;
@property (strong, nonatomic) SearchVC* searchVC;

@property (strong, nonatomic) PrivacyPolicyVC *privacyPolicyVC;
@property (strong, nonatomic) PrivacyPolicyNVC *privacyPolicyNVC;

@property (strong, nonatomic) AboutVC *aboutVC;
@property (strong, nonatomic) AboutNVC *aboutNVC;

@property (strong, nonatomic) PeopleFollowNVC *peopleFollowNVC;
@property (strong, nonatomic) PeopleFollowVC *peopleFollowVC;


@property (strong, nonatomic) PlacesFollowVC *placesFollowVC;
@property (strong, nonatomic) PlacesFollowNVC *placesFollowNVC;

@property (strong, nonatomic) SpecialVC *specialVC;
@property (strong, nonatomic) SpecialNVC *specialNVC;



+ (LayoutManager*)shared;
+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

+ (void)createSlidingVC;

- (void)showSpecialDetails:(CKCampaign*)compaign;

@end