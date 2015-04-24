//
//  CoverView.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 4/23/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "CoverView.h"

@interface CoverView ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation CoverView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.scrollView.frame = self.bounds;
    _scrollView.contentSize = self.bounds.size;
    
    UIView* test = [UIView new];
    test.frame = CGRectMake(0, 0, 100, 100);
    test.backgroundColor = [UIColor redColor];
    
    [self addSubview:test];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
}
@end
