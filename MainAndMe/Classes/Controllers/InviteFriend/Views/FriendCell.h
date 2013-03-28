//
//  SearchCell.h
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (void)setPersonImageURLString:(NSString*)imageURLString;
@end
