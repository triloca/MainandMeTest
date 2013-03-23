//
//  PickerView.m
//  MainAndMe
//
//  Created by Sasha on 3/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PickerView.h"


@interface PickerView()

@end


@implementation PickerView

- (void)awakeFromNib{
    // Init code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
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
