//
//  LeftMenuCell.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/21/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LeftMenuCell.h"

@interface LeftMenuCell ()
@property (strong, nonatomic) JSCustomBadge *badgeView;
@end

@implementation LeftMenuCell

- (void)awakeFromNib {
    // Initialization code
    [self setupBadge];
    [self updateBagePosition];
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


- (void)setupBadge{
    self.badgeView = [JSCustomBadge customBadgeWithString:@"0"
                                                 withStringColor:[UIColor whiteColor]
                                                  withInsetColor:[UIColor colorWithRed:0.216f green:0.737f blue:0.482f alpha:1.00f]
                                                  withBadgeFrame:NO
                                             withBadgeFrameColor:nil
                                                       withScale:1.3
                                                     withShining:NO
                                                      withShadow:NO];
    _badgeView.textFont = [UIFont boldSystemFontOfSize:15];
    [_badgeView autoBadgeSizeWithString:@"1"];
    [self.contentView addSubview:_badgeView];
}

- (void)updateBagePosition{
    CGRect rc = _badgeView.frame;
    rc.origin.x = self.contentView.frame.size.width - rc.size.width - 110;
    _badgeView.frame = rc;
    
    CGPoint center = _badgeView.center;
    center.y = self.contentView.center.y;
    _badgeView.center = center;
}

- (void)setupBageString:(NSString*)text{
    if (!text) {
        return;
    }
    [_badgeView autoBadgeSizeWithString:text];
    [self updateBagePosition];
}

@end
