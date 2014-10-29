//
//  ShopCategoryNVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/23/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ShopCategoryNVC.h"
#import "UIViewController+ECSlidingViewController.h"

@interface ShopCategoryNVC ()

@end

@implementation ShopCategoryNVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //! Add recognizer for finger action
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.view addGestureRecognizer:self.slidingViewController.resetTapGesture];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    [self.view removeGestureRecognizer:self.slidingViewController.resetTapGesture];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
