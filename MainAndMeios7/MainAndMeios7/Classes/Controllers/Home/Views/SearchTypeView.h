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


- (void)selectSpecials;
- (void)selectItems;
- (void)selectStorefronts;

- (void)unselectAll;

@end
