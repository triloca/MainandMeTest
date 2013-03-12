//
//  UIView+Common.h
//  Common
//
//  Created by Viktor Gubriienko on 20.01.10.
//  Copyright 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Common)


@property (nonatomic, assign) CGPoint bottomRightPoint;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) float originX;
@property (nonatomic, assign) float originY;
@property (nonatomic, assign) CGRect rotatedFrame;

- (void) removeSubviewsWithTag:(NSInteger) tag;
- (void) centerViewByX:(BOOL) centerByX byY:(BOOL) centerByY;

- (void) setHeight:(float)aHeight;
- (void) setWidth:(float)aWidth;
- (void) placeInSuperViewMode:(UIViewContentMode)aMode offset:(CGPoint)aOffset;
- (void) placeInRectOfSize:(CGSize)aSize mode:(UIViewContentMode)aMode offset:(CGPoint)aOffset;
- (void) printSubviews;
- (UIView*) findSuperviewWithClass:(Class) superViewClass;
- (UIView*) findSubviewWithClass:(Class) subViewClass;
- (UIViewController*)viewController;
- (void)setTestBackground;
- (void)rotateAnimationWithDuration:(CGFloat)duration;

+ (id)loadViewFromXIB;
+ (id)loadViewFromXIBWithName:(NSString*)xibName;

@end
