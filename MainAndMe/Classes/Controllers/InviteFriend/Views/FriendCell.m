//
//  SearchCell.m
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FriendCell.h"


@interface FriendCell()
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIImageView *personImageView;

@end


@implementation FriendCell

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


- (void)setPersonImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.personImageView  setImageWithURLRequest:request
                                 placeholderImage:[UIImage imageNamed:@"posted_user_ic@2x.png"]
                                     failureImage:nil
                                 progressViewSize:CGSizeMake(_personImageView.bounds.size.width - 5, 4)
                                progressViewStile:UIProgressViewStyleDefault
                                progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                                   trackTintColor:nil
                                       sizePolicy:UNImageSizePolicyScaleAspectFill
                                      cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                          success:nil
                                          failure:nil
                                         progress:nil];
    
}


@end
