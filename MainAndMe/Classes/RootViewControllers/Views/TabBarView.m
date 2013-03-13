//
//  TabBarView.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "TabBarView.h"


@interface TabBarView()

@end


@implementation TabBarView

- (void)awakeFromNib{
    // Init code
}

- (IBAction)tabButtonTouchDown:(UIButton*)sender {
    if (_tabButtonDown) {
        _tabButtonDown(sender ,sender.tag);
    }
}

- (IBAction)photoButtonClicked:(UIButton*)sender {
    if (_tabPhotoButtonClicked) {
        _tabPhotoButtonClicked(sender);
    }
}
@end
