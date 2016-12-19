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
    [super awakeFromNib];
    
    [_specialsButton setTitleColor:[_specialsButton titleColorForState:UIControlStateSelected] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [_itemsButton setTitleColor:[_itemsButton titleColorForState:UIControlStateSelected] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [_storefrontsButton setTitleColor:[_storefrontsButton titleColorForState:UIControlStateSelected] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self selectSpecials];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setStoreBageValueNotification:) name:@"kSetStoreBageValueNotification" object:nil];
    
    [self setStoreBadgeNumber:0];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self updateState];
    
    self.storebadgeContentView.layer.cornerRadius = 2;
}

- (IBAction)specialsButtonDown:(UIButton *)sender {
    [self unselectAll];
    sender.selected = YES;
    sender.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:16];
    
    _searchType = SearchTypeSpecials;

    [self updateState];
}

- (IBAction)itemsButtonDown:(UIButton *)sender {
    [self unselectAll];
    sender.selected = YES;
    sender.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:16];

    _searchType = SearchTypeItems;
    
    [self updateState];
}

- (IBAction)storefrontButtonDown:(UIButton *)sender {
    [self unselectAll];
    sender.selected = YES;
    sender.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:16];

    _searchType = SearchTypeStorefronts;
    
    [self updateState];
}

- (IBAction)specialsButtonUp:(UIButton *)sender {
    if (_didSelectSpecials) {
        _didSelectSpecials(self, sender);
    }
    self.oldSearchType = SearchTypeSpecials;
    
}
- (IBAction)itemsButtonUp:(UIButton *)sender {
    if (_didSelectItems) {
        _didSelectItems(self, sender);
    }
    self.oldSearchType = SearchTypeItems;
}
- (IBAction)storefrontsButtonUp:(UIButton *)sender {
    if (_didSelectStorefronts) {
        _didSelectStorefronts(self, sender);
    }
    self.oldSearchType = SearchTypeStorefronts;
}

- (void)moveBorderToButton:(UIButton*)sender{
    _borderImageView.hidden = NO;
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
    _specialsButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16];
    _itemsButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16];
    _storefrontsButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16];


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
    
    if (_hideTriger) {
        _borderImageView.hidden = YES;
        //[self unselectAll];
    }
}


- (void)setHideTriger:(BOOL)hideTriger{
    _hideTriger = hideTriger;
    [self updateState];
}


- (void)setStoreBadgeNumber:(NSInteger)value{

    self.storesBadgeLabel.text = [NSString stringWithFormat:@"%d", value];
    
    if (value == 0) {
        self.storebadgeContentView.hidden = YES;
    }else{
        self.storebadgeContentView.hidden = NO;
    }
    
    [self layoutIfNeeded];
}


- (void)setStoreBageValueNotification:(NSNotification*)notif{

    NSNumber* value = notif.object;
    if ([value isKindOfClass:[NSNumber class]]) {
        [self setStoreBadgeNumber:[value integerValue]];
    }
}

@end
