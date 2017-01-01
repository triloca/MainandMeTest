//
//  HomeVC.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchTypeView.h"

@interface HomeVC : UIViewController

@property (strong, nonatomic) SearchTypeView *searchTypeView;

- (void)didLoginSuccessfuly;
- (void)updateStore:(NSDictionary*)storeDict;

- (void)removeCoverViewAnimated:(BOOL)animated;
- (void)showAddressController;
- (void)cameraButtinCliced:(UIButton*)button;

@end
