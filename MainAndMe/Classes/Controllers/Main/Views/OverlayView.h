//
//  OveralyView.h
//  MainAndMe
//
//  Created by Sasha on 3/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface OverlayView : UIView
@property (copy, nonatomic) void (^didClickOverlay)();
@end
