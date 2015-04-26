//
//  ProductDetailsVC.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 11.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailsVC : UIViewController

@property (strong, nonatomic) NSDictionary *product;

- (id) initWithProduct: (NSDictionary *) product;

@property (strong, nonatomic) NSArray* productsArray;
@property (assign, nonatomic) NSInteger index;

@end
