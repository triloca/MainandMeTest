//
//  CommentCell.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"
#import "DataManager.h"


@interface CommentCell()
//@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *personImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UILabel *agoLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end


@implementation CommentCell

+ (CGSize)textSize:(NSString*)text{
    // Calculating cell height
    return [(text ? text : @"") sizeWithFont:[CommentCell textFont]
                           constrainedToSize:CGSizeMake(274, 9999)
                               lineBreakMode:UILineBreakModeWordWrap];
    
}

+ (CGFloat)cellHeight:(NSString*)text{
    // Calculating cell height
    CGSize textSize = [CommentCell textSize:text];
    textSize.height += 43;
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
    _messageLabel.font = [CommentCell textFont];
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
    
    CGSize textSize = [CommentCell textSize:messageText];
    CGFloat cellHeight = [CommentCell cellHeight:messageText];
    
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

- (void)setPersonImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.personImageView  setImageWithURLRequest:request
                                 placeholderImage:[UIImage imageNamed:@"posted_user_ic@2x.png"]
                                     failureImage:nil
                                 progressViewSize:CGSizeMake(_personImageView.bounds.size.width - 5, 4)
                                progressViewStile:UIProgressViewStyleDefault
                                progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                                   trackTintColor:nil
                                       sizePolicy:UNImageSizePolicyScaleAspectFill
                                      cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                          success:nil
                                          failure:nil
                                         progress:nil];
    
}



- (void)setCellData:(NSDictionary *)cellData{

    [self setPersonImageURLString:[cellData safeStringObjectForKey:@"avatar_url"]];
    
    NSDate* date = [DataManager dateFromString:[cellData safeStringObjectForKey:@"created_at"]];
    _agoLabel.text = [DataManager howLongAgo:date];
    
    _nameLabel.text = [cellData safeStringObjectForKey:@"username"];

}

@end
