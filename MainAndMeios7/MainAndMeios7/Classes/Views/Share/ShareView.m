//
//  ShareView.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 5/17/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "ShareView.h"

@interface ShareView ()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *pinterestButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;

@end

@implementation ShareView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _cancelButton.layer.cornerRadius = 5;
}

- (IBAction)onCanlceButton:(id)sender {
    if (_didClickCancelButton) {
        _didClickCancelButton(self, sender);
    }
}

- (IBAction)shareButtonCliched:(id)sender {
    if (_didClickShareButton) {
        _didClickShareButton(self, sender);
    }
}
@end
