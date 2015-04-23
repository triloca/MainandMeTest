//
//  HighlightingTableViewCell.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 14.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "HighlightingTableViewCell.h"

@implementation HighlightingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    int padding = 8;
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(padding, self.frame.size.height-1, self.frame.size.width - padding * 2, 0.5)];
    separator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    separator.backgroundColor = [UIColor grayColor];
    separator.alpha = 0.5f;
    [self addSubview:separator];
    self.titleLabel.font = [UIFont fontWithName:CellFontNormal size:CellFontSize];
}

- (void) setBacklighted:(BOOL)backlighted {
    _backlighted = backlighted;
    
    if (backlighted) {
        self.backgroundColor = kAppColorYellow;
        self.titleLabel.font = [UIFont fontWithName:CellFontHighlighted size:CellFontSize];
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont fontWithName:CellFontNormal size:CellFontSize];
    }
}

@end
