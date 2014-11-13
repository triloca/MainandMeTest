//
//  LayoutManager.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/17/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LayoutManager.h"


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
    [self shared].homeVC = [HomeVC loadFromXIB_Or_iPhone5_XIB];
    [self shared].homeNVC = [[HomeNVC alloc] initWithRootViewController:[self shared].homeVC];
    
    [self shared].slidingVC.topViewController = [self shared].homeNVC;
    
    //! Left VC
    [self shared].LeftMenuVC = [LeftMenuVC loadFromXIB_Or_iPhone5_XIB];
    [self shared].slidingVC.underLeftViewController = [self shared].LeftMenuVC;
    
    // enable swiping on the top view
    [[self shared].homeNVC.view addGestureRecognizer:[self shared].slidingVC.panGesture];
    
    [self shared].rootNVC.viewControllers = @[[self shared].slidingVC];

}

- (ShopCategoryNVC*)shopCategoryNVC{
    if (_shopCategoryNVC == nil) {
        self.shopCategoryVC = [ShopCategoryVC loadFromXIB_Or_iPhone5_XIB];
        self.shopCategoryNVC = [[ShopCategoryNVC alloc] initWithRootViewController:_shopCategoryVC];
    }
    return _shopCategoryNVC;
}

- (PrivacyPolicyNVC*)privacyPolicyNVC{
    if (_privacyPolicyNVC == nil) {
        self.privacyPolicyVC = [PrivacyPolicyVC loadFromXIB_Or_iPhone5_XIB];
        self.privacyPolicyNVC = [[PrivacyPolicyNVC alloc] initWithRootViewController:_privacyPolicyVC];
    }
    return _privacyPolicyNVC;
}

- (PlacesFollowNVC*)placesFollowNVC{
    if (_placesFollowNVC == nil) {
        self.placesFollowVC = [PlacesFollowVC loadFromXIB_Or_iPhone5_XIB];
        self.placesFollowNVC = [[PlacesFollowNVC alloc] initWithRootViewController:_placesFollowVC];
    }
    return _placesFollowNVC;
}
#pragma mark _______________________ Notifications _________________________



@end
