//
//  RootViewController.m
//  qwe
//
//  Created by Sasha Bukov on 4/30/12.
//  Copyright (c) 2012 Company. All rights reserved.
//

#import "RootViewController.h"
#import "TabBarView.h"
#import "UIView+Common.h"

@interface RootViewController ()
@property (strong, nonatomic) TabBarView* tabBarView;
@end


@implementation RootViewController

@synthesize rootTabBarController;

- (id)init
{
    self = [super init];
    if (self) {
        self.rootTabBarController = [[UITabBarController alloc] init];
    }
    return self;
}

- (void) loadView {
    
    [super loadView];
}

- (UIView*) view {
    
    [super view];
    
    return self.rootTabBarController.view;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tabBarView = [TabBarView loadViewFromXIB];
    
    __unsafe_unretained RootViewController* weakSelf = self;
    _tabBarView.tabButtonDown = ^(UIButton* sender, NSInteger index){
        [weakSelf.rootTabBarController setSelectedIndex:index];
//        UINavigationController* navVC = [weakSelf.rootTabBarController.viewControllers safeObjectAtIndex:index];
//        [navVC popToRootViewControllerAnimated:NO]; //! Add if needed
    };

    _tabBarView.tabPhotoButtonClicked = ^(UIButton* sender){

    };

    
    [rootTabBarController.tabBar addSubview:_tabBarView];
    CGRect rc = _tabBarView.frame;

    rc.origin.y -= rc.size.height - rootTabBarController.tabBar.frame.size.height;
    _tabBarView.frame =rc;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

@end
