//
//  StorefrontsHorisontalCollectionCell.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/18/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreDataModel.h"

@interface StorefrontsHorisontalCollectionCell : UICollectionViewCell
@property (copy, nonatomic) void (^didClickProduct)(StorefrontsHorisontalCollectionCell* obj, NSDictionary* prod);

@property (copy, nonatomic) void (^didClickCall)(StorefrontsHorisontalCollectionCell* obj, StoreDataModel* storeDataModel);
@property (copy, nonatomic) void (^didClickShare)(StorefrontsHorisontalCollectionCell* obj, StoreDataModel* storeDataModel);
@property (copy, nonatomic) void (^didClickFollow)(StorefrontsHorisontalCollectionCell* obj, StoreDataModel* storeDataModel);

@property (strong, nonatomic) StoreDataModel* storeDataModel;
@end
