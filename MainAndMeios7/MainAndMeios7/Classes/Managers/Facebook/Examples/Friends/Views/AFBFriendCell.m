//
//  AFBFriendCell.m
//  AllComponents
//
//  Created by Sasha on 4/27/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//

#import "AFBFriendCell.h"


@interface AFBFriendCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end


@implementation AFBFriendCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)setupAvatarURLString:(NSString*)urlString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [_avatarImageView setImageWithURLRequest:request
                            placeholderImage:nil
                                failureImage:nil
                            progressViewSize:CGSizeZero
                           progressViewStile:UIProgressViewStyleDefault
                           progressTintColor:nil
                              trackTintColor:nil
                                  sizePolicy:UNImageSizePolicyScaleAspectFill
                                 cachePolicy:UNImageCachePolicyMemoryCache
                                     success:nil
                                     failure:nil
                                    progress:nil];
}


@end
