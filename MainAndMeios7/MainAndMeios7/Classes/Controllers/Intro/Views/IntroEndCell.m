//
//  IntroCell.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "IntroEndCell.h"

@implementation IntroEndCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (IBAction)endTutorialButtonClicked:(id)sender {
    if (_didClickEndTutorial) {
        _didClickEndTutorial(self);
    }
}
- (IBAction)seeTownsButtonClicked:(id)sender {
    if (_didClickSeeTowns) {
        _didClickSeeTowns(self);
    }
}

- (IBAction)addItemButtonClicked:(id)sender {
    if (_didClickAddItem) {
        _didClickAddItem(self);
    }
}
- (IBAction)addLocalBussines:(id)sender {
    if (_didClickAddLocalBussines) {
        _didClickAddLocalBussines(self);
    }
}
- (IBAction)windshopButtonClicked:(id)sender {
    if (_didClickWindshop) {
        _didClickWindshop(self);
    }
}
- (IBAction)seeBenefitsButtonClicked:(id)sender {
    if (_didClickSeeBenefits) {
        _didClickSeeBenefits(self);
    }
}
    
@end
