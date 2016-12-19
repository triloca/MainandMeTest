//
//  StorefrontsHorisontalCollectionView.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/18/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StorefrontsHorisontalCollectionView : UIView
@property (strong, nonatomic) UIViewController* parrentVC;
@property (strong, nonatomic) NSMutableArray* collectionArray;
- (void)reloadData;
@end
