//
//  OveralyView.m
//  MainAndMe
//
//  Created by Sasha on 3/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "OverlayView.h"


@interface OverlayView()

@end


@implementation OverlayView

- (void)awakeFromNib{
    // Init code
}


- (IBAction)overlayButtonClicked:(id)sender {
    if (_didClickOverlay) {
        _didClickOverlay();
    }
}

@end
