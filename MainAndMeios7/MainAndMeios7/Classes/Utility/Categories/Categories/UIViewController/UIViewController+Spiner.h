//
//  UIViewController+Spiner.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIViewController (Spiner)

- (void)showSpinnerWithName:(NSString*)name;
- (void)showSpinnerWithName:(NSString *)name andStyle:(UIActivityIndicatorViewStyle)style;
- (void)showSpinnerWithName:(NSString *)name andStyle:(UIActivityIndicatorViewStyle)style insets:(UIEdgeInsets)insets;

- (void)hideSpinnerWithName:(NSString*)name;
- (void)hideAllSpiners;

@end
