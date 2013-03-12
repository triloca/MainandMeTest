//
//  UIImage+Resizing.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface UIImage(Resizing)

//! Resize image to the specified size
- (UIImage*) imageResizedToSize: (CGSize) size;
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

@end