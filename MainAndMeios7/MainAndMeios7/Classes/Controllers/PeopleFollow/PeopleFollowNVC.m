//
//  PeopleFollowNVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 16.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PeopleFollowNVC.h"

@interface PeopleFollowNVC ()
@property UIStatusBarStyle oldStyle;
@end

@implementation PeopleFollowNVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationBar.barTintColor = [UIColor whiteColor];//kAppColorGreen;
    //self.navigationBar.tintColor = [UIColor whiteColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.oldStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:_oldStyle animated:animated];
}

@end
