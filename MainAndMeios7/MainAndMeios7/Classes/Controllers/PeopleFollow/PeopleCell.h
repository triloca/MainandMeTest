//
//  PeopleCell.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 16.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HighlightingTableViewCell.h"

@interface PeopleCell : HighlightingTableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *peopleImageView;

- (void) setUser: (NSDictionary *) user;

@end
