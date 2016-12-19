//
//  ProductCollectionCell.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/19/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductView.h"


@interface ProductCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *productContentView;
@property (strong, nonatomic) ProductView* productView;

@property (strong, nonatomic) NSDictionary* productInfo;

@end
