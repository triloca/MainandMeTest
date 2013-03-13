//
//  TabBarView.h
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface TabBarView : UIView
@property (copy, nonatomic) void (^tabButtonDown)(UIButton* sender, NSInteger index);
@property (copy, nonatomic) void (^tabPhotoButtonClicked)(UIButton* sender);
@end

