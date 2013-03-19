//
//  ProductHorizontalCell.h
//  MainAndMe
//
//  Created by Sasha on 2/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface ProductHorizontalCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *itemImageView;
@property (retain, nonatomic) IBOutlet UILabel *itemTextLabel;

@property (copy, nonatomic) void (^didClickAtIndex)(NSInteger index);

- (void)setImageURLString:(NSString*)imageURLString;
@end
