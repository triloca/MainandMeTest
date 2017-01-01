//
//  IntroCell.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "IntroCell.h"

@implementation IntroCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)skipButonClicked:(id)sender {
    if (_didClickEndTutorial) {
        _didClickEndTutorial(self);
    }
}

@end
