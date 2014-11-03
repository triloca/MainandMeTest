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

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(anchorRight)];
    self.navigationItem.title = @"Layout Demo";
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
