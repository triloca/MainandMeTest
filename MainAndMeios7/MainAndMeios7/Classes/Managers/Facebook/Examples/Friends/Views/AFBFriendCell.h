//
//  AFBFriendCell.h
//  AllComponents
//
//  Created by Sasha on 4/27/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//


@interface AFBFriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)setupAvatarURLString:(NSString*)urlString;
@end
