//
//  PeopleCell.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 16.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PeopleCell.h"

@implementation PeopleCell

- (void) setUser: (NSDictionary *) user {
    self.titleLabel.text = [user safeStringObjectForKey:@"name"];
    [self setupAvatarURLString:[user safeStringObjectForKey:@"avatar_url"]];
}


- (void)setupAvatarURLString:(NSString*)urlString {
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [_peopleImageView setImageWithURLRequest:request
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
