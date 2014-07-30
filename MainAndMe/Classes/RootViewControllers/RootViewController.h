//
//  RootViewController.h
//  qwe
//
//  Created by Sasha Bukov on 4/30/12.
//  Copyright (c) 2012 Company. All rights reserved.
//

#import "GAITrackedViewController.h"


@interface RootViewController : /*UIViewController*/GAITrackedViewController

@property (strong, nonatomic) UITabBarController* rootTabBarController;
- (void)hidePhotoView;
- (void)loadPhotoButtonClicked:(id)sender;
@end
