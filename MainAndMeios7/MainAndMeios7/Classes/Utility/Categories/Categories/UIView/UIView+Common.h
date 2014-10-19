//
//  UIView+Common.h
//  Common
//
//  Created by Viktor Gubriienko on 20.01.10.
//  Copyright 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Common)

@property (nonatomic, assign) CGRect rotatedFrame;

+ (id)loadViewFromXIB;
+ (id)loadViewFromXIB_or_iPhone5_XIB;
+ (id)loadViewFromXIBWithName:(NSString*)xibName;

@end
