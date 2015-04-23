//
//  SearchView.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchView : UIView

@property (strong, nonatomic) NSDictionary* storeDict;

@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;

@property (weak, nonatomic) IBOutlet UIImageView *gradientImageView;
@property (weak, nonatomic) IBOutlet UIImageView *storeImageView;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (copy, nonatomic) void (^didSelectCategory)(SearchView* view, NSDictionary* category);

@property (copy, nonatomic) void (^didSelectAllCategory)(SearchView* view, NSDictionary* category);

- (void)sortDataAssending:(BOOL)value;
@end
