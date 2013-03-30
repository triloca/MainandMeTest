//
//  ProductDetailsCell.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductDetailsCell.h"
#import "UILabel+Common.h"

@interface ProductDetailsCell()

@property (weak, nonatomic) IBOutlet UIImageView *personImageView;
@property (weak, nonatomic) IBOutlet UIButton *storeNameButton;

@end


@implementation ProductDetailsCell

- (void)awakeFromNib{
    // Init code
    _storeNameLabel.textColor = [UIColor colorWithRed:125/255.0f green:121/255.0f blue:127/255.0f alpha:1];
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

- (void)setName:(NSString*)name{
    
    _storeNameLabel.text = name;
    [_storeNameLabel resizeToStretch];
    CGRect rc = _storeNameLabel.frame;
    if (rc.size.width > 250){
        rc.size.width = 250;
    }
    
    _storeNameLabel.frame = rc;
    
    UIView* lineView = [UIView new];
    lineView.frame = CGRectMake(0, rc.size.height - 3, rc.size.width, 1);
    lineView.backgroundColor = [UIColor grayColor];
    [_storeNameLabel addSubview:lineView];
    _storeNameLabel.backgroundColor = [UIColor clearColor];
    _storeNameButton.frame = _storeNameLabel.frame;
}

- (IBAction)storeNameButtonDown:(id)sender {
    _storeNameLabel.textColor = [UIColor colorWithRed:81/255.0f green:55/255.0f blue:16/255.0f alpha:1];
}

- (IBAction)storeNameButtonClicked:(id)sender {
    _storeNameLabel.textColor = [UIColor colorWithRed:125/255.0f green:121/255.0f blue:127/255.0f alpha:1];
    if (_didClickStoreName) {
        _didClickStoreName(self);
    }

}

- (IBAction)storeNameButtonUpOutside:(id)sender {
    _storeNameLabel.textColor = [UIColor colorWithRed:125/255.0f green:121/255.0f blue:127/255.0f alpha:1];
}

@end
