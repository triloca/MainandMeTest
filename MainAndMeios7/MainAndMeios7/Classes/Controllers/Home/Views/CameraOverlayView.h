//
//  CameraOverlayView.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 5/8/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraOverlayView : UIView

@property (copy, nonatomic) void (^onCameraButton)(CameraOverlayView* view, UIButton* button);

@property (copy, nonatomic) void (^onCancelButton)(CameraOverlayView* view, UIButton* button);

@end
