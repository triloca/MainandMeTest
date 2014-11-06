//
//  HomeCell.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/3/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "HomeCell.h"

@interface HomeCell ()


@end

@implementation HomeCell

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 3;
    self.clipsToBounds = YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect rc = _mainImageView.frame;
    rc.size.height = self.frame.size.height - (218 - 148);
    _mainImageView.frame = rc;
}

@end
