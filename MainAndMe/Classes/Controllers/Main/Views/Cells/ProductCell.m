//
//  ProductCell.m
//  MainAndMe
//
//  Created by Sasha on 2/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductCell.h"
#import "UIView+Common.h"


@interface ProductCell()

@end


@implementation ProductCell

- (void)awakeFromNib{
    self.firstView = [ProductView loadViewFromXIB];
    self.secondView = [ProductView loadViewFromXIB];
    self.thirdView = [ProductView loadViewFromXIB];
    
    CGRect rc;
    rc = _secondView.frame;
    rc.origin.x = 107;
    _secondView.frame = rc;
    rc = _thirdView.frame;
    rc.origin.x = 214;
    _thirdView.frame = rc;
    
    
    [_firstView.coverButton addTarget:self
                               action:@selector(coverButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    [_secondView.coverButton addTarget:self
                               action:@selector(coverButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    [_thirdView.coverButton addTarget:self
                               action:@selector(coverButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.contentView addSubview:_firstView];
    [self.contentView addSubview:_secondView];
    [self.contentView addSubview:_thirdView];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void) layoutSubviews {
    [super layoutSubviews];

}


- (void)coverButtonClicked:(UIButton*)sender{
    if (_didClickAtIndex) {
        _didClickAtIndex(sender.tag);
    }
}
@end
