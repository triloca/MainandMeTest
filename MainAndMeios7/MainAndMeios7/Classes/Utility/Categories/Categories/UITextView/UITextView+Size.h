//
//  UITextView+Size.h
//  TennisBattle
//
//  Created by Sasha on 6/15/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Size)
+(CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
@end
