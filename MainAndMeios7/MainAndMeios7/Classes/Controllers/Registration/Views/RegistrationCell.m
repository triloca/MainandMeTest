//
//  RegistrationCell.m
//  MainAndMeios7
//
//  Created by Bhumi Shah on 03/11/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RegistrationCell.h"

@implementation RegistrationCell
@synthesize txtTitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
