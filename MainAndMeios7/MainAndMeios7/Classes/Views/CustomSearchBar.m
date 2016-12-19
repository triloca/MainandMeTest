//
//  CustomSearchBar.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 4/25/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "CustomSearchBar.h"

@implementation CustomSearchBar

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self updateColors];
//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
//    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textfield.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}];

    
//    NSDictionary *placeholderAttributes = @{
//                                            NSForegroundColorAttributeName: [UIColor whiteColor],
//                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15],
//                                            };
//    
//    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder
//                                                                                attributes:placeholderAttributes];
//    
//    [[UITextField appearanceWhenContainedIn:[CustomSearchBar class], nil] setAttributedPlaceholder:attributedPlaceholder];
}

- (void)layoutSubviews{
    [super layoutSubviews];
   
}

- (void)updateColors{

    UIView* topCoverView = [UIView new];
    topCoverView.backgroundColor = [UIColor colorWithRed:0.929f green:0.925f blue:0.925f alpha:1.00f];
    topCoverView.frame = CGRectMake(0, 0, self.frame.size.width, 1);
    topCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:topCoverView];
    
    UIView* bottomCoverView = [UIView new];
    bottomCoverView.backgroundColor = [UIColor colorWithRed:0.929f green:0.925f blue:0.925f alpha:1.00f];
    bottomCoverView.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    bottomCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:bottomCoverView];
    
    [self setSearchFieldBackgroundImage:[UIImage imageNamed:@"scope_bar_background3.png"]forState:UIControlStateNormal];

}

@end
