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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // configure anchored layout
    //self.anchorRightPeekAmount  = 100.0;
    //self.anchorLeftRevealAmount = 100.0;
    //self.anchorRightPeekAmount = 100;
    self.anchorRightRevealAmount = 242;
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
