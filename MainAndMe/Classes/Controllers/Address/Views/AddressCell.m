//
//  SearchCell.m
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AddressCell.h"


@interface AddressCell()
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@end


@implementation AddressCell

- (void)awakeFromNib{
    // Init code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        _backImageView.image = [UIImage imageNamed:@"list_selecter_bar@2x.png"];
    }else{
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             _backImageView.image = [UIImage imageNamed:@"all_store_active_list_bar@2x.png"];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}


- (void) layoutSubviews {
    [super layoutSubviews];
    
    //    if(UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad)
    //    {
    //    }
    //    
    
    //    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //    
    //    if (UIInterfaceOrientationIsLandscape(orientation))
    //    {
    //    }
    
    //    self.customImageView.frame = CGRectMake(2, 2, 40, 40);
    //    self.customLable.frame = CGRectMake(50, 2, 100, 40);
    
}

@end
