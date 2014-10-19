//
//  UILabel+Size.m
//  myPomodora
//
//  Created by Sasha on 10/17/13.
//
//

#import "UILabel+Size.h"

@implementation UILabel (Size)


- (CGSize)expectedSize{
    
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width, 9999);
    CGSize size = [self expectedSizeForRectWithSize:maximumLabelSize];

    return size;
}

//CGSize maximumLabelSize = CGSizeMake(self.frame.size.width, 9999);
- (CGSize)expectedSizeForRectWithSize:(CGSize)maximumLabelSize{
    
    CGSize size;
    
        NSRange range = NSMakeRange(0, [self.attributedText length]);
        
        NSDictionary *attributes = [self.attributedText attributesAtIndex:0 effectiveRange:&range];
        CGSize boundingBox = [self.text boundingRectWithSize:maximumLabelSize
                                                     options: NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:attributes
                                                     context:nil].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));

    return size;
}


@end
