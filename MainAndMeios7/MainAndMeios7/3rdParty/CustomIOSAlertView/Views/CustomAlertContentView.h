//
//  CustomAlertContentView.h
//  MainAndMeios7
//
//  Created by Alexanedr on 5/23/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlertContentView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (copy, nonatomic) void (^didClickCloseButton)(CustomAlertContentView* view, UIButton* button);
@end
