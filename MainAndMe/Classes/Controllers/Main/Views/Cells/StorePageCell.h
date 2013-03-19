//
//  PageCell.h
//  MainAndMe
//
//  Created by Sasha on 3/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface StorePageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *productsLabel;


@property (strong, nonatomic) NSDictionary* cellData;
@property (strong, nonatomic) NSDictionary* cellProfileData;
@property (copy, nonatomic) void (^didClickAtIndex)(NSInteger index);

- (void)setPersonImageURLString:(NSString*)imageURLString;
@end
