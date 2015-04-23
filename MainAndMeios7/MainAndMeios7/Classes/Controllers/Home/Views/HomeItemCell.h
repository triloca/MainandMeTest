//
//  HomeItemCell.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/3/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMQuiltViewCell.h"

@interface HomeItemCell : TMQuiltViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *descrLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (strong, nonatomic) NSDictionary* storeDict;

@property (copy, nonatomic) void (^didClickStoreButton)(HomeItemCell* cell, UIButton* sender, NSDictionary* productDict);
@property (copy, nonatomic) void (^didClickPriceButton)(HomeItemCell* cell, UIButton* sender, NSDictionary* productDict);



@property (weak, nonatomic, readonly) UIButton *storeButton;


+ (CGFloat)cellHeghtForStore:(NSDictionary*)storeDict;

@end
