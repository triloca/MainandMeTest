//
//  LeftMenuCell.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/21/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSCustomBadge.h"


@interface LeftMenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic, readonly) JSCustomBadge *badgeView;

- (void)setupBageString:(NSString*)text;

@end
