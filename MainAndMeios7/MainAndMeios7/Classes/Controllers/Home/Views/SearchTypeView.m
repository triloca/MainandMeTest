//
//  SearchTypeView.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/2/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SearchTypeView.h"

@interface SearchTypeView ()
@property (weak, nonatomic) IBOutlet UIButton *specialsButton;
@property (weak, nonatomic) IBOutlet UIButton *itemsButton;
@property (weak, nonatomic) IBOutlet UIButton *storefrontsButton;
@property (weak, nonatomic) IBOutlet UIImageView *borderImageView;

@property (assign, nonatomic) ViewSearchType searchType;

@end

@implementation SearchTypeView


- (void)awakeFromNib{
    [_specialsButton setTitleColor:[_specialsButton titleColorForState:UIControlStateSelected] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [_itemsButton setTitleColor:[_itemsButton titleColorForState:UIControlStateSelected] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [_storefrontsButton setTitleColor:[_storefrontsButton titleColorForState:UIControlStateSelected] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self selectSpecials];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self updateState];
}

- (IBAction)specialsButtonDown:(UIButton *)sender {
    [self unselectAll];
    sender.selected = YES;
    sender.titleLabel.font = [UIFont fontWithName:@"DINbek Bold" size:14];
    
    _searchType = SearchTypeSpecials;

    [self updateState];
}

- (IBAction)itemsButtonDown:(UIButton *)sender {
    [self unselectAll];
    sender.selected = YES;
    sender.titleLabel.font = [UIFont fontWithName:@"DINbek Bold" size:14];

    _searchType = SearchTypeItems;
    
    [self updateState];
}

- (IBAction)storefrontButtonDown:(UIButton *)sender {
    [self unselectAll];
    sender.selected = YES;
    sender.titleLabel.font = [UIFont fontWithName:@"DINbek Bold" size:14];

    _searchType = SearchTypeStorefronts;
    
    [self updateState];
}

- (IBAction)specialsButtonUp:(UIButton *)sender {
    if (_didSelectSpecials) {
        _didSelectSpecials(self, sender);
    }
}
- (IBAction)itemsButtonUp:(UIButton *)sender {
    if (_didSelectItems) {
        _didSelectItems(self, sender);
    }
}
- (IBAction)storefrontsButtonUp:(UIButton *)sender {
    if (_didSelectStorefronts) {
        _didSelectStorefronts(self, sender);
    }
}

- (void)moveBorderToButton:(UIButton*)sender{
    CGRect rc = _borderImageView.frame;
    rc.size.width = sender.frame.size.width;
    _borderImageView.frame = rc;
    
    CGPoint center = _borderImageView.center;
    center.x = sender.center.x;
    _borderImageView.center = center;
    
}

- (void)unselectAll{
    _specialsButton.selected = NO;
    _itemsButton.selected = NO;
    _storefrontsButton.selected = NO;
    
    _specialsButton.titleLabel.font = [UIFont fontWithName:@"DINBek" size:14];
    _itemsButton.titleLabel.font = [UIFont fontWithName:@"DINBek" size:14];
    _storefrontsButton.titleLabel.font = [UIFont fontWithName:@"DINBek" size:14];


}

- (void)selectSpecials{
    [self specialsButtonDown:_specialsButton];
}

- (void)selectItems{
     [self specialsButtonDown:_itemsButton];
}

- (void)selectStorefronts{
    [self storefrontButtonDown:_storefrontsButton];
}

- (void)updateState{
    switch (_searchType) {
        case SearchTypeSpecials:
            [self moveBorderToButton:_specialsButton];
            break;
        case SearchTypeItems:
            [self moveBorderToButton:_itemsButton];
            break;
        case SearchTypeStorefronts:
            [self moveBorderToButton:_storefrontsButton];
            break;
            
        default:
            break;
    }
}

@end