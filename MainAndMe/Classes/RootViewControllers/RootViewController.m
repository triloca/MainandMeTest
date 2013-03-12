//
//  RootViewController.m
//  qwe
//
//  Created by Sasha Bukov on 4/30/12.
//  Copyright (c) 2012 Company. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize rootTabBarController;

- (void) loadView {
    
    [super loadView];
    
    self.rootTabBarController = [[UITabBarController alloc] init];
}

- (UIView*) view {
    
    [super view];
    
    return self.rootTabBarController.view;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

@end
