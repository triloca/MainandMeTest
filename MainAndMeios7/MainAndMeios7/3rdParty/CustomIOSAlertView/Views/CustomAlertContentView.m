//
//  CustomAlertContentView.m
//  MainAndMeios7
//
//  Created by Alexanedr on 5/23/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "CustomAlertContentView.h"

@implementation CustomAlertContentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)closeButtonClicked:(id)sender {
    if (_didClickCloseButton) {
        _didClickCloseButton(self, sender);
    }
}

@end
