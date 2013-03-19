//
//  ProductDetailsCell.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductDetailsCell.h"


@interface ProductDetailsCell()

@property (weak, nonatomic) IBOutlet UIImageView *personImageView;

@end


@implementation ProductDetailsCell

- (void)awakeFromNib{
    // Init code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
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


- (void)setProductImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.productImageView  setImageWithURLRequest:request
                           placeholderImage:nil
                               failureImage:nil
                           progressViewSize:CGSizeMake(_productImageView.bounds.size.width - 30, 8)
                          progressViewStile:UIProgressViewStyleDefault
                          progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                             trackTintColor:nil
                                 sizePolicy:UNImageSizePolicyScaleAspectFill
                                cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                    success:nil
                                    failure:nil
                                   progress:nil];
    
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
