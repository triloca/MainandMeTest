//
//  PlacesFollowCell.m
//  MainAndMeios7
//
//  Created by Max on 11/8/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PlacesFollowCell.h"

@interface PlacesFollowCell ()

@end

@implementation PlacesFollowCell

- (void)awakeFromNib {
    // Initialization code
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
   /* if (selected) {
        UIView *backView = [[UIView alloc] initWithFrame:self.selectedBackgroundView.frame];
        [backView setBackgroundColor:[UIColor colorWithRed:255/255.f green:252/255.f blue:171/255.f alpha:1.0]];
        [self setSelectedBackgroundView:backView];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    }else{
       // _nameLabel.textColor = [UIColor colorWithRed:0.286f green:0.278f blue:0.278f alpha:1.00f];
       
    }*/
}


@end
