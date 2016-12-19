//
//  SpecialCell.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProximityKitManager.h"

@interface SpecialCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) NSDictionary *cellInfo;

@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@end
