//
//  UIColor+Additions.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@implementation UIColor(Additions)


+ (UIColor*) colorWithARGB: (NSUInteger) value
{
	CGFloat a = ((value & 0xFF000000) >> 24) / 255.0;
	CGFloat r = ((value & 0x00FF0000) >> 16) / 255.0;
	CGFloat g = ((value & 0x0000FF00) >> 8 ) / 255.0;
	CGFloat b = ((value & 0x000000FF)      ) / 255.0;
	
	return [UIColor colorWithRed: r green: g blue: b alpha: a];
}


+ (UIColor*) colorWithRGB: (NSUInteger) value
{
	return [UIColor colorWithARGB: value | 0xFF000000];
}


@end