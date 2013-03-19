//
//  ProductHorizontalCell.m
//  MainAndMe
//
//  Created by Sasha on 2/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductHorizontalCell.h"
#import "UIImageView+UNNetworking.h"


@interface ProductHorizontalCell()
@property (retain, nonatomic) IBOutlet UIImageView *backImageView;

@end


@implementation ProductHorizontalCell

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

- (void)setImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.itemImageView  setImageWithURLRequest:request
                                placeholderImage:nil
                                    failureImage:nil
                                progressViewSize:CGSizeMake(_itemImageView.bounds.size.width - 20, 7)
                               progressViewStile:UIProgressViewStyleDefault
                               progressTintColor:nil
                                  trackTintColor:nil
                                      sizePolicy:UNImageSizePolicyScaleAspectFill
                                     cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                         success:nil
                                         failure:nil
                                        progress:nil];
    
}


#pragma mark - Buttons Action
- (IBAction)coverButtonClicked:(id)sender {
    _backImageView.alpha = 1;
   
    if (_didClickAtIndex) {
        _didClickAtIndex(_itemImageView.tag);
    }
}

- (IBAction)coverButtonTouchDown:(UIButton *)sender {
    _backImageView.alpha = 0.3;
}

@end
