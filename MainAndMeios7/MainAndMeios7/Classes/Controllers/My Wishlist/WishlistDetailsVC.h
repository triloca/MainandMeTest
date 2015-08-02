//
//  WishlistDetailsVC.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.12.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMQuiltView.h"


@interface WishlistDetailsVC : UIViewController <TMQuiltViewDelegate, TMQuiltViewDataSource>

@property (strong, nonatomic) NSDictionary *wishlist;

@property (assign, nonatomic) BOOL needUpdateData;
@end
