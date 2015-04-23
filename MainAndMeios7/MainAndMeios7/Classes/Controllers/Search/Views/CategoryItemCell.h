//
//  CategoryItemCell.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/3/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMQuiltViewCell.h"

@interface CategoryItemCell : TMQuiltViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UILabel *descrLabel;

@end
