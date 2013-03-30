//
//  ProductDetailsCell.h
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface StoreDetailsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *postedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *agoLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIImageView *followImageView;

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;

- (void)setPersonImageURLString:(NSString*)imageURLString;
- (void)setProductImageURLString:(NSString*)imageURLString;
@end
