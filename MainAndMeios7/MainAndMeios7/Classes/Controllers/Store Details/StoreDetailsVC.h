//
//  StoreDetailsVC.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreDetailsVC : UIViewController

@property (strong, nonatomic) NSDictionary* storeDict;

@property (strong, nonatomic) NSArray* storesArray;
@property (assign, nonatomic) NSInteger index;

@end
