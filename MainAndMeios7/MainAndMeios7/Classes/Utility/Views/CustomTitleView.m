//
//  CustomTitleView.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 09.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "CustomTitleView.h"

@interface CustomTitleView(Private)

@end

#define kContentPadding 10
#define MAX_WIDTH 200

@implementation CustomTitleView

- (id) initWithTitle: (NSString *) title dropDownIndicator: (BOOL) shouldShowDropdown clickCallback: (TitleClickedCallback) callback {
    if (self = [super initWithFrame:CGRectMake(0, 0, 90, 30)]) {
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(kContentPadding, 0, self.frame.size.width-kContentPadding*2, self.frame.size.height)];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentPadding, 0, _contentView.frame.size.width-kContentPadding*2, _contentView.frame.size.height)];
        self.dropdownIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_title_down_arrow"]];
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.dropdownIndicatorView];
        [self addSubview:self.contentView];
        self.contentView.layer.cornerRadius = 6;

        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont fontWithName:@"Whitney-Bold" size:18];
        self.title = title;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.titleLabel sizeToFit];
        
        self.contentView.backgroundColor = kAppColorGreen;
        self.dropdownIndicatorView.backgroundColor = [UIColor clearColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];

        self.shouldShowDropdownIndicator = shouldShowDropdown;
        
        self.clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.clickButton.frame = self.frame;
        self.clickButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.clickButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.clickButton setAdjustsImageWhenHighlighted:YES];
        self.callback = callback;
        
        [self.contentView addSubview:_clickButton];
        [self setNeedsLayout];

    }
    return self;
}

- (void) clickButton: (id) sender {
    if (_callback)
        self.callback(self);
}

- (void) layoutSubviews {
    [super layoutSubviews];

    NSLog(@"Layout");
    if (_shouldShowDropdownIndicator) {
        float fullWidth = self.titleLabel.frame.size.width + _dropdownIndicatorView.frame.size.width + kContentPadding;
        
        float w = fullWidth > MAX_WIDTH ? MAX_WIDTH : fullWidth;
        float label_width = fullWidth - _dropdownIndicatorView.frame.size.width - kContentPadding;
        
        float innerPadding = (self.frame.size.width - w - kContentPadding*2)/2;
        self.contentView.frame = CGRectMake(innerPadding, 0, w+kContentPadding*2, self.frame.size.height);
        self.titleLabel.frame = CGRectMake(kContentPadding, (self.contentView.frame.size.height - self.titleLabel.frame.size.height)/2.f, label_width, _titleLabel.frame.size.height);
        self.dropdownIndicatorView.frame = CGRectMake(kContentPadding + label_width + kContentPadding, (self.contentView.frame.size.height - _dropdownIndicatorView.image.size.height)/2, _dropdownIndicatorView.image.size.width, _dropdownIndicatorView.image.size.height);
        
    } else {
        float fullWidth = self.titleLabel.frame.size.width;
        float w = fullWidth > MAX_WIDTH ? MAX_WIDTH : fullWidth;
        float label_width = w;
        
        float innerPadding = (self.frame.size.width - w - kContentPadding*2)/2;
        self.contentView.frame = CGRectMake(innerPadding, 0, w+kContentPadding*2, self.frame.size.height);
        self.titleLabel.frame = CGRectMake(kContentPadding, (self.contentView.frame.size.height - self.titleLabel.frame.size.height)/2, label_width, _titleLabel.frame.size.height);
        
    }
}

- (void) setTitle:(NSString *)title {
    if (title == _title)
        return;
    
    _title = title;
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}

- (void) setShouldShowDropdownIndicator:(BOOL)shouldShowDropdownIndicator {
    _shouldShowDropdownIndicator = shouldShowDropdownIndicator;
    
    if (_shouldShowDropdownIndicator) {
        [self.contentView addSubview:self.dropdownIndicatorView];
    } else {
        [self.dropdownIndicatorView removeFromSuperview];
    }
    
    [self setNeedsLayout];
}

@end
