//
//  PickerView.m
//  MainAndMe
//
//  Created by Sasha on 3/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PickerView.h"


@interface PickerView()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end


@implementation PickerView

- (void)awakeFromNib{
    // Init code
    _cancelButton.target = self;
    _cancelButton.action = @selector(cancelButtonClicked);
    _doneButton.target = self;
    _doneButton.action = @selector(doneButtonClicked);
}

- (void)cancelButtonClicked{
    if (_didClickCancel) {
        _didClickCancel();
    }
}

- (void)doneButtonClicked{
    if (_didClickDone) {
        _didClickDone();
    }
}

@end
