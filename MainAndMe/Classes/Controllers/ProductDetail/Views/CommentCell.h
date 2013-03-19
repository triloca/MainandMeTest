//
//  CommentCell.h
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface CommentCell : UITableViewCell

@property (strong, nonatomic) NSDictionary* cellData;

+ (CGFloat)cellHeight:(NSString*)text;
- (void)setMessageText:(NSString *)messageText;
- (void)setPersonImageURLString:(NSString*)imageURLString;
@end
