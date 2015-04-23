//
//  ShopCategoryVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/23/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ShopCategoryVC.h"

@interface ShopCategoryVC ()

@end

@implementation ShopCategoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // configure top view controller
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = anchorLeftButton;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}



@end
