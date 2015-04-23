//
//  WishlistPickerVC.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.12.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^WishListPickerCallback) (NSDictionary *dict);

@interface WishlistPickerVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) WishListPickerCallback onSelectWishlistCallback;

- (void) loadWishlists;

@property (strong, nonatomic) NSMutableArray *items;

@property (strong, nonatomic) NSString *userId;

@end
