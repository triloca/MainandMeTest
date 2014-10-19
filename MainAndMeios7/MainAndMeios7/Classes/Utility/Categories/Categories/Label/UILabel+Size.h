//
//  UILabel+Size.h
//  myPomodora
//
//  Created by Sasha on 10/17/13.
//
//

#import <UIKit/UIKit.h>

@interface UILabel (Size)

- (CGSize)expectedSize;

- (CGSize)expectedSizeForRectWithSize:(CGSize)maximumLabelSize;


@end
