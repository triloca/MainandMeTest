//
//  CameraOverlayView.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 5/8/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "CameraOverlayView.h"

@implementation CameraOverlayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)onCameraButton:(id)sender {
    if (_onCameraButton) {
        _onCameraButton(self, sender);
    }
}

- (IBAction)onCancelButton:(id)sender {
    if (_onCancelButton) {
        _onCancelButton(self, sender);
    }
}

@end
