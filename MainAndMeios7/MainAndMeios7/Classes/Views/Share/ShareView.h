//
//  ShareView.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 5/17/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareView : UIView
@property (copy, nonatomic) void (^didClickCancelButton)(ShareView* view, UIButton* button);
@property (copy, nonatomic) void (^didClickShareButton)(ShareView* view, UIButton* button);

@end
