//
//  LayoutManager.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/17/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LayoutManager.h"
#import "SpecialDetailsVC.h"


@interface LayoutManager()

@end


@implementation LayoutManager
#pragma mark _______________________ Class Methods _________________________

#pragma mark - Shared Instance and Init
+ (LayoutManager *)shared {
    
    static LayoutManager *shared = nil;
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

+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //! Set Application Delegate
    [self shared].appDelegate = (AppDelegate*)application.delegate;
    
    //! Set Winodw
    [self shared].window = [self shared].appDelegate.window;
    [self shared].window.backgroundColor = [UIColor purpleColor];
    
    //! Set Storyboard
    [self shared].mainStoryboard = [self shared].window.rootViewController.storyboard;
    
    //! Set root navigation controller
    [self shared].rootNVC = (RootNavigationController*)[self shared].window.rootViewController;
    
    [self createSlidingVC];
    
    //! Background for logout screen changing
    [self shared].window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"signin_background.png"]];
    
}

//! Call after logout to create new controllers
+ (void)createSlidingVC{
    
    [self shared].slidingVC = [[SlidingVC alloc] initWithNibName:@"SlidingVC" bundle:nil];
    
    
    //! First controller to show
    [self shared].homeVC = [HomeVC loadFromXIBForScrrenSizes];
    [self shared].homeNVC = [[HomeNVC alloc] initWithRootViewController:[self shared].homeVC];
    
    [self shared].slidingVC.topViewController = [self shared].homeNVC;
    
    //! Left VC
    [self shared].LeftMenuVC = [LeftMenuVC loadFromXIBForScrrenSizes];
    [self shared].slidingVC.underLeftViewController = [self shared].LeftMenuVC;
    
    // enable swiping on the top view
    [[self shared].homeNVC.view addGestureRecognizer:[self shared].slidingVC.panGesture];
    
    [self shared].rootNVC.viewControllers = @[[self shared].slidingVC];

}

- (BaseNavigationController *) myWishlistNVC {
    if (_myWishlistNVC == nil) {
        self.myWishlistVC = [MyWishlistVC loadFromXIBForScrrenSizes];
        _myWishlistVC.userId = [CommonManager shared].userId;
        self.myWishlistNVC = [[BaseNavigationController alloc] initWithRootViewController:_myWishlistVC];
    }
    return _myWishlistNVC;
}

- (BaseNavigationController *) storesByNameNVC {
    //if (_storesByNameNVC == nil) {
        self.storesByNameVC = [StoresByNameVC loadFromXIBForScrrenSizes];
        self.storesByNameNVC = [[BaseNavigationController alloc] initWithRootViewController:_storesByNameVC];
    //}
    return _storesByNameNVC;
}

- (BaseNavigationController *) notificationsNVC {
    if (_notificationsNVC == nil) {
        self.notificationsVC = [NotificationsVC loadFromXIBForScrrenSizes];
        self.notificationsNVC = [[BaseNavigationController alloc] initWithRootViewController:_notificationsVC];
    }
    return _notificationsNVC;
}

- (ProfileNVC *) profileNVC {
    if (_profileNVC == nil) {
        self.profileVC = [ProfileVC loadFromXIBForScrrenSizes];
        self.profileVC.isMenu = YES;
        self.profileVC.isEditable =YES;
        self.profileNVC = [[ProfileNVC alloc] initWithRootViewController:_profileVC];
    }
    return _profileNVC;
}

- (AboutNVC *) aboutNVC {
    if (_aboutNVC == nil) {
        self.aboutVC = [AboutVC loadFromXIBForScrrenSizes];
        self.aboutNVC = [[AboutNVC alloc] initWithRootViewController:_aboutVC];
    }
    return _aboutNVC;
}

- (ShopCategoryNVC*)shopCategoryNVC{
    if (_shopCategoryNVC == nil) {
        self.shopCategoryVC = [ShopCategoryVC loadFromXIBForScrrenSizes];
        self.shopCategoryNVC = [[ShopCategoryNVC alloc] initWithRootViewController:_shopCategoryVC];
    }
    return _shopCategoryNVC;
}

- (SearchNVC*)searchNVC{
    if (_searchNVC == nil) {
        self.searchVC = [SearchVC loadFromXIBForScrrenSizes];
        self.searchNVC = [[SearchNVC alloc] initWithRootViewController:_searchVC];
    }
    return _searchNVC;
}


- (PrivacyPolicyNVC*)privacyPolicyNVC{
    if (_privacyPolicyNVC == nil) {
        self.privacyPolicyVC = [PrivacyPolicyVC loadFromXIBForScrrenSizes];
        self.privacyPolicyNVC = [[PrivacyPolicyNVC alloc] initWithRootViewController:_privacyPolicyVC];
    }
    return _privacyPolicyNVC;
}

- (SponsoredByNVC*)sponsoredByNVC{
    if (_sponsoredByNVC == nil) {
        self.sponsoredByVC = [SponsoredByVC loadFromXIBForScrrenSizes];
        self.sponsoredByNVC = [[SponsoredByNVC alloc] initWithRootViewController:_sponsoredByVC];
    }
    return _sponsoredByNVC;
}


- (PeopleFollowNVC*) peopleFollowNVC{
    if (_peopleFollowNVC == nil) {
        self.peopleFollowVC = [PeopleFollowVC loadFromXIBForScrrenSizes];
        self.peopleFollowNVC = [[PeopleFollowNVC alloc] initWithRootViewController:_peopleFollowVC];
    }
    return _peopleFollowNVC;
}

- (PlacesFollowNVC*) placesFollowNVC{
    if (_peopleFollowNVC == nil) {
        self.placesFollowVC = [PlacesFollowVC loadFromXIBForScrrenSizes];
        self.placesFollowNVC = [[PlacesFollowNVC alloc] initWithRootViewController:_placesFollowVC];
    }
    return _placesFollowNVC;
}

- (SpecialNVC*)specialNVC{
    if (_specialNVC == nil) {
        self.specialVC = [SpecialVC loadFromXIBForScrrenSizes];
        self.specialNVC = [[SpecialNVC alloc] initWithRootViewController:_specialVC];
    }
    return _specialNVC;
}

- (void)showSpecialDetails:(CKCampaign*)compaign{
    
    SpecialDetailsVC* specialDetailsVC = [SpecialDetailsVC loadFromXIBForScrrenSizes];
    specialDetailsVC.campaign = compaign;
    [[LayoutManager shared].rootNVC pushViewController:specialDetailsVC animated:YES];
}

- (void)showHomeControllerAnimated:(BOOL)animated{
    self.slidingVC.topViewController = self.homeNVC;
}

#pragma mark _______________________ Notifications _________________________



@end
