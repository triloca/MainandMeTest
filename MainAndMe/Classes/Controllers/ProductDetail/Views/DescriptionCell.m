//
//  CommentCell.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DescriptionCell.h"
#import "DataManager.h"


@interface DescriptionCell()
//@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end


@implementation DescriptionCell

+ (CGSize)textSize:(NSString*)text{
    // Calculating cell height
    return [(text ? text : @"") sizeWithFont:[DescriptionCell textFont]
                           constrainedToSize:CGSizeMake(306, 9999)
                               lineBreakMode:UILineBreakModeWordWrap];
    
}

+ (CGFloat)cellHeight:(NSString*)text{
    // Calculating cell height
    CGSize textSize = [DescriptionCell textSize:text];
    textSize.height += 33;
    if (textSize.height < 20) {
        return 20;
    }
    return textSize.height;
}

+ (UIFont*)textFont{
    return [UIFont systemFontOfSize:12];
}



- (void)awakeFromNib{
    // Init code
    _messageLabel.font = [DescriptionCell textFont];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void) layoutSubviews {
    [super layoutSubviews];
    
    //    if(UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad)
    //    {
    //    }
    //    
    
    //    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //    
    //    if (UIInterfaceOrientationIsLandscape(orientation))
    //    {
    //    }
    
    //    self.customImageView.frame = CGRectMake(2, 2, 40, 40);
    //    self.customLable.frame = CGRectMake(50, 2, 100, 40);
    
}


- (void)setMessageText:(NSString *)messageText{
    
    CGSize textSize = [DescriptionCell textSize:messageText];
    CGFloat cellHeight = [DescriptionCell cellHeight:messageText];
    
    CGRect rc = self.contentView.frame;
    rc.size.height = cellHeight;
    self.contentView.frame = rc;
    
    rc = _messageLabel.frame;
    rc.size.height = textSize.height;
    _messageLabel.frame = rc;
    
    rc = _backImageView.frame;
    rc.size.height = cellHeight;
    _backImageView.frame = rc;
    
    _messageLabel.text = messageText;
}

@end
