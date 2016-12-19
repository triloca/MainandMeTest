//
//  StorefrontView.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/19/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreDataModel.h"
@interface StorefrontView : UIView
@property (copy, nonatomic) void (^didClickProduct)(StorefrontView* obj, NSDictionary* prod);
@property (copy, nonatomic) void (^didClickCall)(StorefrontView* obj, StoreDataModel* storeDataModel);
@property (copy, nonatomic) void (^didClickShare)(StorefrontView* obj, StoreDataModel* storeDataModel);
@property (copy, nonatomic) void (^didClickFollow)(StorefrontView* obj, StoreDataModel* storeDataModel);

@property (strong, nonatomic) StoreDataModel* storeDataModel;
@end
