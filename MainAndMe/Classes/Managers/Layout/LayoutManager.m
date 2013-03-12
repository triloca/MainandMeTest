//
//  LayoutManager.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "LayoutManager.h"
#import "RootNavigationController.h"
#import "RootViewController.h"
#import "SplashScreenViewController.h"
#import "LoginViewController.h"


@interface LayoutManager()
@property (strong, nonatomic) UINavigationController* rootNavigationController;
@property (strong, nonatomic) UIViewController* rootTabBarController;
@end


@implementation LayoutManager

#pragma mark - Shared Instance and Init
+ (LayoutManager *)shared {
    
    static LayoutManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
        _appDelegate = [UIApplication sharedApplication].delegate;
    }
    return self;
}

#pragma mark - 
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [self loadGUI];
}


#pragma mark- Load GUI

- (void) loadGUI{
    
    
    SplashScreenViewController* splashScreenViewController = [SplashScreenViewController loadFromXIB_Or_iPhone5_XIB];
    __unsafe_unretained SplashScreenViewController* weak_splashScreenViewController = splashScreenViewController;
    splashScreenViewController.timeOutBlock = ^(){
        [weak_splashScreenViewController.navigationController popViewControllerAnimated:NO];
    };
    
    LoginViewController* loginViewController = [LoginViewController loadFromXIB_Or_iPhone5_XIB];
    
    self.rootTabBarController = [RootViewController new];
    
    self.rootNavigationController = [RootNavigationController new];
    _rootNavigationController.viewControllers = [NSArray arrayWithObject:_rootTabBarController];
    [_rootNavigationController pushViewController:loginViewController animated:NO];
    [_rootNavigationController pushViewController:splashScreenViewController animated:NO];
    
    _appDelegate.window.rootViewController = self.rootNavigationController;
}

@end
