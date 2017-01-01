//
//  SearchTypeView.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/2/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SearchTypeStorefronts = 0,
    SearchTypeItems,
    SearchTypeSpecials
} ViewSearchType;


@interface SearchTypeView : UIView
@property (copy, nonatomic) void (^didSelectSpecials)(SearchTypeView* view, UIButton* button);
@property (copy, nonatomic) void (^didSelectItems)(SearchTypeView* view, UIButton* button);
@property (copy, nonatomic) void (^didSelectStorefronts)(SearchTypeView* view, UIButton* button);

@property (assign, nonatomic, readonly) ViewSearchType searchType;
@property (assign, nonatomic) BOOL hideTriger;

@property (assign, nonatomic) ViewSearchType oldSearchType;

@property (weak, nonatomic) IBOutlet UILabel *storesBadgeLabel;
@property (weak, nonatomic) IBOutlet UIView *storebadgeContentView;


- (void)selectSpecials;
- (void)selectItems;
- (void)selectStorefronts;

- (IBAction)specialsButtonUp:(UIButton *)sender;
- (IBAction)itemsButtonUp:(UIButton *)sender;
- (IBAction)storefrontsButtonUp:(UIButton *)sender;

- (void)unselectAll;

- (void)setStoreBadgeNumber:(NSInteger)value;

@end
