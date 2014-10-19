//
//  UITextView+Size.m
//  TennisBattle
//
//  Created by Sasha on 6/15/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//

#import "UITextView+Size.h"

@implementation UITextView (Size)


+(CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    

        CGRect frame = [text boundingRectWithSize:size
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil];
        return frame.size;

}

@end
