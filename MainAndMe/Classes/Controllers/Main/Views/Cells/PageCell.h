//
//  PageCell.h
//  MainAndMe
//
//  Created by Sasha on 3/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface PageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;


@property (strong, nonatomic) NSDictionary* cellData;
@property (strong, nonatomic) NSDictionary* cellProfileData;
@property (copy, nonatomic) void (^didClickAtIndex)(NSInteger index);

- (void)setPersonImageURLString:(NSString*)imageURLString;
@end
