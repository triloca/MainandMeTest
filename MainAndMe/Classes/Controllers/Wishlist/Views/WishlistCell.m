//
//  WishlistCell.m
//  MainAndMe
//
//  Created by Sasha on 3/16/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "WishlistCell.h"


@interface WishlistCell()
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end


@implementation WishlistCell

- (void)awakeFromNib{
    // Init code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        _coverView.hidden = NO;
    }else{
    
        [UIView animateWithDuration:0.3
                         animations:^{
                             _coverView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             _coverView.hidden = YES;
                             _coverView.alpha = 1;
                         }];
    }
}


- (void) layoutSubviews {
    [super layoutSubviews];
    
    //    if(UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad)
    //    {
    //    }
    //    
    
    //    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //    
    //    if (UIInterfaceOrientationIsLandscape(orientation))
    //    {
    //    }
    
    //    self.customImageView.frame = CGRectMake(2, 2, 40, 40);
    //    self.customLable.frame = CGRectMake(50, 2, 100, 40);
    
}

@end
