//
//  SlidingVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SlidingVC.h"

@interface SlidingVC ()

@end

@implementation SlidingVC

#pragma mark _______________________ Class Methods _________________________



#pragma mark ____________________________ Init _____________________________

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


- (void)dealloc{
    
}

#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.anchorRightRevealAmount = 242;
    
    [LoginVC loginVCPresentation:^(LoginVC *loginVC) {
        UINavigationController* loginNVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
        
        [loginVC view];
        
        [[LayoutManager shared].rootNVC presentViewController:loginNVC
                                                     animated:NO
                                                   completion:^{}];
        
    }
                         success:^(LoginVC *loginVC, NSString *token) {
                             [loginVC.navigationController dismissViewControllerAnimated:YES
                                                                              completion:^{}];
                         }
                         failure:^(LoginVC *loginVC, NSError *error) {
                             
                         }
                 alreadyLoggedIn:^(LoginVC *loginVC, NSString *token) {
                     
                 }];
    
}

#pragma mark _______________________ Privat Methods(view)___________________
//! Update views by model
- (void)updateViews{
    
}

#pragma mark _______________________ Privat Methods ________________________



#pragma mark _______________________ Buttons Action ________________________



#pragma mark _______________________ Delegates _____________________________



#pragma mark _______________________ Public Methods ________________________



#pragma mark _______________________ Notifications _________________________




@end
