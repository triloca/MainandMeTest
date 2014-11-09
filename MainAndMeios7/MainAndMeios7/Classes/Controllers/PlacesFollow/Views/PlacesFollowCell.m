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
    
    if (selected) {
        _nameLabel.textColor = [UIColor whiteColor];
    }else{
        _nameLabel.textColor = [UIColor colorWithRed:0.286f green:0.278f blue:0.278f alpha:1.00f];
    }
}


@end
