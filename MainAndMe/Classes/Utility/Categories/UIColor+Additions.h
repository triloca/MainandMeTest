//
//  UIColor+Additions.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface UIColor(Additions)

//! Create color based on specified hexadecimal representation
+ (UIColor*) colorWithARGB: (NSUInteger) value;

//! Create color based on specified hexadecimal representation
+ (UIColor*) colorWithRGB: (NSUInteger) value;

@end