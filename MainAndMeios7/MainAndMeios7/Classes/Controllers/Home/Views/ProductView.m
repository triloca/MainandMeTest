//
//  ProductView.m
//  MainAndMe
//
//  Created by Sasha on 2/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductView.h"
#import "UIImageView+UNNetworking.h"


@interface ProductView()

@property (assign, nonatomic) BOOL isVibrationActive;
@end


@implementation ProductView

- (void)awakeFromNib{
    // Init code
    _textLabel.font = [UIFont fontWithName:@"GillSans" size:14];
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
    
    [self.imageView  setImageWithURLRequest:request
                               placeholderImage:nil
                                   failureImage:nil
                               progressViewSize:CGSizeMake(_imageView.bounds.size.width - 20, 5)
                              progressViewStile:UIProgressViewStyleDefault
                              progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
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
}

- (IBAction)coverButtonTouchDown:(UIButton *)sender {
    _backImageView.alpha = 0.3;
}

- (IBAction)coverButtonUpOutSide:(id)sender {
     _backImageView.alpha = 1;
}
- (void)startVibration{
    if (_isVibrationActive) {
        return;
    }
     _isVibrationActive = YES;
    [self vibroAnimation];
}

- (void)stopVibration{
    _isVibrationActive = NO;
    _imageView.transform = CGAffineTransformIdentity;
    _backImageView.transform = CGAffineTransformIdentity;
}
- (void)vibroAnimation{
    if (!_isVibrationActive) {
        _imageView.transform = CGAffineTransformIdentity;
        _backImageView.transform = CGAffineTransformIdentity;
        return;
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         _imageView.transform = CGAffineTransformMakeRotation(0.02);
                         _backImageView.transform = CGAffineTransformMakeRotation(0.02);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              _imageView.transform = CGAffineTransformMakeRotation(-0.02);
                                              _backImageView.transform = CGAffineTransformMakeRotation(-0.02);
                                          }
                                          completion:^(BOOL finished) {
                                              [self vibroAnimation];
                                          }];
                         
                     }];

}
@end
