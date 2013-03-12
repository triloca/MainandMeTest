//
//  UIView+Common.m
//  Common
//
//  Created by Viktor Gubriienko on 20.01.10.
//  Copyright 2010. All rights reserved.
//

#import "UIView+Common.h"
#import <QuartzCore/QuartzCore.h>

@interface UIView (Common_Private) 

+ (void) printChildsForView:(UIView*) view withInd:(NSUInteger) ind;

@end

@implementation UIView (Common)

@dynamic bottomRightPoint;
@dynamic origin;
@dynamic size;
@dynamic originX;
@dynamic originY;
@dynamic rotatedFrame;

- (void) removeSubviewsWithTag:(NSInteger) tag {
	
	UIView *viewToRemove = nil;
	while ( (viewToRemove = [self viewWithTag:tag]) ) {
		[viewToRemove removeFromSuperview];
	}
	
}

- (void)setTestBackground{
	self.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];  
}

- (void) centerViewByX:(BOOL) centerByX byY:(BOOL) centerByY {
	
	if ( !centerByX && !centerByY  ) {
		return;
	}
	
	CGRect viewFrame = self.frame;
	CGRect superviewBounds = [self superview].bounds;
	
	if ( centerByX ) {
		viewFrame.origin.x = roundf((superviewBounds.size.width / 2.0f - viewFrame.size.width / 2.0f));
	}

	if ( centerByY ) {
		viewFrame.origin.y = roundf((superviewBounds.size.height / 2.0f - viewFrame.size.height / 2.0f));		
	}

	self.frame = viewFrame;
	
}

- (void) setRotatedFrame:(CGRect) value {
    CGFloat rotateShift = (value.size.width - value.size.height) / 2;
    self.transform = CGAffineTransformIdentity;
    self.frame = CGRectMake(rotateShift + value.origin.x, -rotateShift + value.origin.y, value.size.height, value.size.width);
    self.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f); 
}

- (CGRect) rotatedFrame {
    return CGRectZero;
}

- (CGPoint) origin{
	return self.frame.origin;
}

- (void) setOrigin:(CGPoint)aPoint{
	self.frame = CGRectMake(aPoint.x, aPoint.y, self.frame.size.width, self.frame.size.height);
}

- (CGSize) size{
	return self.frame.size;
}

- (void) setSize:(CGSize)aSize{
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, aSize.width, aSize.height);
}

- (float) originX {
	return self.frame.origin.x;
}

- (void) setOriginX:(float)aX{
	CGRect r = self.frame;
	r.origin.x = aX;
	self.frame = r;
}

- (float) originY {
	return self.frame.origin.y;
}

- (void) setOriginY:(float)aY{
	CGRect r = self.frame;
	r.origin.y = aY;
	self.frame = r;
}

- (void) setHeight:(float)aHeight{
	CGRect r = self.frame;
	r.size.height = aHeight;
	self.frame = r;
}

- (void) setWidth:(float)aWidth{
	CGRect r = self.frame;
	r.size.width = aWidth;
	self.frame = r;
}


- (void) placeInSuperViewMode:(UIViewContentMode)aMode offset:(CGPoint)aOffset{
	[self placeInRectOfSize:self.superview.frame.size mode:aMode offset:aOffset];
}

- (void) placeInRectOfSize:(CGSize)aSize mode:(UIViewContentMode)aMode offset:(CGPoint)aOffset{
	CGPoint viewPoint = CGPointZero;
	CGSize viewSize = self.bounds.size;
	if (aMode < UIViewContentModeCenter || aMode > UIViewContentModeBottomRight){
		return;
	}
	if (aMode == UIViewContentModeCenter || aMode == UIViewContentModeTop || aMode == UIViewContentModeBottom){
		viewPoint.x = aSize.width/2.0 - viewSize.width / 2.0; 
	}
	else if (aMode == UIViewContentModeRight || aMode == UIViewContentModeTopRight || aMode == UIViewContentModeBottomRight){
		viewPoint.x = aSize.width - viewSize.width; 
	}
	
	if (aMode == UIViewContentModeCenter || aMode == UIViewContentModeLeft || aMode == UIViewContentModeRight){
		viewPoint.y = aSize.height /2.0 - viewSize.height / 2.0; 
	}
	else if (aMode == UIViewContentModeBottomRight || aMode == UIViewContentModeBottom || aMode == UIViewContentModeBottomLeft){
		viewPoint.y = aSize.height - viewSize.height;  
	}
	self.center = CGPointMake(viewPoint.x + viewSize.width / 2.0 + aOffset.x, viewPoint.y + viewSize.height / 2.0 + aOffset.y);
}

- (void) printSubviews {
	NSLog(@"Printing subviews of [%@]", self);
	NSLog(@"--------------------------------------------BEGIN");
	[UIView printChildsForView:self withInd:0];
	NSLog(@"--------------------------------------------END");
}

- (UIView*) findSuperviewWithClass:(Class) superViewClass {
	
	UIView *currentSuperView = self.superview;
	while ( currentSuperView != nil && ![currentSuperView isKindOfClass:superViewClass] ) {
		currentSuperView = currentSuperView.superview;
	}
	
	return currentSuperView;
}

- (UIView*) findSubviewWithClass:(Class) subViewClass {
    if ( [self isKindOfClass:subViewClass] ) {
        return self;
    } else {
        for (UIView *aView in self.subviews) {
            UIView *subView = [aView findSubviewWithClass:subViewClass];
            if ( subView != nil ) {
                return subView;
            }
        }
        return nil;
    }
}

- (UIViewController*)viewController {
	for (UIView* next = self; next; next = next.superview) {
		UIResponder* nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}

- (void) setBottomRightPoint:(CGPoint)aPoint{
    [self setOrigin:CGPointMake(aPoint.x - self.frame.size.width, aPoint.y - self.frame.size.height)];
}

- (CGPoint) bottomRightPoint {
    return CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
}



#pragma mark -
#pragma mark Private

+ (void) printChildsForView:(UIView*) view withInd:(NSUInteger) ind {
	NSString *indText = @"";
	int i;
	for (i = 0; i < ind; i++) {
		indText = [indText stringByAppendingString:@"-"];
	}
	NSLog(@"%@ [%@]:%d", indText, [view class], ind);
	for (UIView *child in view.subviews) {
		[[self class] printChildsForView:child withInd: ind + 1];
	}
}

#pragma mark - Rotate animation
- (void)rotateAnimationWithDuration:(CGFloat)duration {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = @0.0f;
    rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = HUGE_VAL;
    [self.layer addAnimation:rotationAnimation forKey:@"spinner"]; 
}

+ (id)loadViewFromXIB {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    if ( [topLevelObjects count] > 0 ) {
        return [topLevelObjects objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (id)loadViewFromXIBWithName:(NSString*)xibName {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:xibName owner:nil options:nil];
    if ( [topLevelObjects count] > 0 ) {
        return [topLevelObjects objectAtIndex:0];
    } else {
        return nil;
    }
}

@end
