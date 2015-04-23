//
//  BaseNavigationController.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 13.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.translucent = NO;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    //! Add recognizer for finger action
    [self.navigationBar addGestureRecognizer:self.slidingViewController.panGesture];
    [self.navigationBar addGestureRecognizer:self.slidingViewController.resetTapGesture];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationBar removeGestureRecognizer:self.slidingViewController.panGesture];
    [self.navigationBar removeGestureRecognizer:self.slidingViewController.resetTapGesture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
