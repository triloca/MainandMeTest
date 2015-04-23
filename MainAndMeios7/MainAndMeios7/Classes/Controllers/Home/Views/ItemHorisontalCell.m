//
//  ItemHorisontalCell.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ItemHorisontalCell.h"

@interface ItemHorisontalCell()

@property (strong, nonatomic) NSDictionary *product;

@end
@implementation ItemHorisontalCell

- (void) awakeFromNib {
    [self.contentView sendSubviewToBack:_gradientView];
    [self.contentView sendSubviewToBack:_imageView];
}

- (void) setProduct: (NSDictionary *) product {
    if (_product == product)
        return;
    
    _product = product;
    _gradientView.hidden = YES;
    _descriptionLabel.text = @"Loading...";
    _titleLabel.text = @"";
    NSDictionary* imagesDict = [_product safeDictionaryObjectForKey:@"image"];

    NSString* mainImageURL = @"";
    mainImageURL = [imagesDict safeStringObjectForKey:@"full"];

    [self setupImageURL:mainImageURL];
    [self.contentView setNeedsLayout];
}

- (void)setupImageURL:(NSString*)urlString{
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    __weak ItemHorisontalCell *wself = self;
    [_imageView setImageWithURLRequest:request
                      placeholderImage:nil
                          failureImage:nil
                      progressViewSize:CGSizeMake(_imageView.frame.size.width - 16, 10)
                     progressViewStile:UIProgressViewStyleDefault
                     progressTintColor:[UIColor colorWithRed:136/255.0f green:173/255.0f blue:230/255.0f alpha:1]
                        trackTintColor:[UIColor whiteColor]
                            sizePolicy:UNImageSizePolicyScaleAspectFill
                           cachePolicy:UNImageCachePolicyMemoryAndFileCache
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   wself.titleLabel.text = [wself.product safeStringObjectForKey:@"name"];
                                   wself.descriptionLabel.text = [[wself.product safeStringObjectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                   wself.gradientView.hidden = NO;

                                   
                               }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                   NSLog(@"Image Failed");
                               }
                              progress:^(NSURLRequest *request, NSHTTPURLResponse *response, float progress) {
                                  
                              }];
    
}

@end
