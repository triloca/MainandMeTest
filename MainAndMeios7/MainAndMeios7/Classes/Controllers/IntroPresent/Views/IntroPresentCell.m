//
//  IntroCell.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "IntroPresentCell.h"

@implementation IntroPresentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (IBAction)chatButtonClicked:(id)sender {
    if (_didClickChatButton) {
        _didClickChatButton(self);
    }
}

- (IBAction)homeButtonClicked:(id)sender {
    if (_didClickHomeButton) {
        _didClickHomeButton(self);
    }

}

@end
