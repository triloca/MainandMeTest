//
//  UIImage+Resizing.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "UIImage+Resizing.h"


@implementation UIImage(Resizing)


- (UIImage*) imageResizedToSize: (CGSize) size
{
	// Check for Retina display and then double the size of image (we assume size is in points)
	if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
	{
		CGFloat scale = [[UIScreen mainScreen] scale];
		
		size.width  *= scale;
		size.height *= scale;
	}

	
	// Create context on which image will be drawn
	UIGraphicsBeginImageContext(size);
	
	// Draw image on this context used provided size
	[self drawInRect: CGRectMake(0, 0, size.width, size.height)];
	
	// Convert context to an image
	UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();    

	// Remove context
	UIGraphicsEndImageContext();
	
	
	return resizedImage;
}



- (UIImage *)scaleToSize:(CGSize)size {
    CGFloat sizeAspectRatio = size.width / size.height;
    CGFloat imageAspectRatio = self.size.width / self.size.height;
 
   CGImageRef imageRef = [self CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
   
    if (alphaInfo == kCGImageAlphaNone)
     alphaInfo = kCGImageAlphaNoneSkipLast;
    
   CGContextRef bitmap = CGBitmapContextCreate(NULL,size.width,size.height,
                                                   CGImageGetBitsPerComponent(imageRef),
                                                   4 * size.width,
                                                   CGImageGetColorSpace(imageRef),alphaInfo
                                                   );
    
    CGFloat scaleFactor;
    if (imageAspectRatio < sizeAspectRatio) {
        scaleFactor = size.width / self.size.width;
        CGContextDrawImage(bitmap, CGRectMake(0, - 0.5 * scaleFactor * self.size.height, size.width, scaleFactor * self.size.height), imageRef);
        } else {
            scaleFactor = size.height / self.size.height;
            CGContextDrawImage(bitmap, CGRectMake(- 0.5 * (scaleFactor * self.size.width - size.width), 0, scaleFactor * self.size.width, size.height), imageRef);
        }
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}

- (UIImage *)uncompressedImage {
    
    return [self scaleToSize:self.size];
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage; 
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
    
}


@end