//
//  CustomTitleView.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 09.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomTitleView;

typedef void (^TitleClickedCallback) (CustomTitleView* titleView);

@interface CustomTitleView : UIView

- (id) initWithTitle: (NSString *) title dropDownIndicator: (BOOL) shouldShowDropdown clickCallback: (TitleClickedCallback) callback;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *dropdownIndicatorView;
@property (strong, nonatomic) UIButton *clickButton;
@property (strong, nonatomic) TitleClickedCallback callback;

@property (nonatomic) BOOL shouldShowDropdownIndicator;

@end
