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

@dynamic rotatedFrame;


- (void) setRotatedFrame:(CGRect) value {
    CGFloat rotateShift = (value.size.width - value.size.height) / 2;
    self.transform = CGAffineTransformIdentity;
    self.frame = CGRectMake(rotateShift + value.origin.x, -rotateShift + value.origin.y, value.size.height, value.size.width);
    self.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f); 
}

- (CGRect) rotatedFrame {
    return CGRectZero;
}


+ (id)loadViewFromXIB {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    if ( [topLevelObjects count] > 0 ) {
        return [topLevelObjects objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (id)loadViewFromXIB_or_iPhone5_XIB {
    
    NSArray *topLevelObjects = nil;
    BOOL isScreen568 = (fabs((double)[[ UIScreen mainScreen] bounds].size.height - (double)568 ) < DBL_EPSILON );
    if(isScreen568){
        NSString* xibName = [NSString stringWithFormat:@"%@_iPhone5", NSStringFromClass(self)];
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:xibName
                                                                 owner:nil
                                                               options:nil];
    }else{
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self)
                                                        owner:nil
                                                      options:nil];
    }

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
