//
//  SearchTypeView.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/2/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SearchTypeSpecials = 0,
    SearchTypeItems,
    SearchTypeStorefronts
} SearchType;


@interface SearchTypeView : UIView
@property (copy, nonatomic) void (^didSelectSpecials)(SearchTypeView* view, UIButton* button);
@property (copy, nonatomic) void (^didSelectItems)(SearchTypeView* view, UIButton* button);
@property (copy, nonatomic) void (^didSelectStorefronts)(SearchTypeView* view, UIButton* button);


- (void)selectSpecials;
- (void)selectItems;
- (void)selectStorefronts;

@end
