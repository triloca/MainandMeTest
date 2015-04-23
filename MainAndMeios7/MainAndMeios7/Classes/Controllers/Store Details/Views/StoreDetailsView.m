//
//  StoreDetailsView.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "StoreDetailsView.h"

@interface StoreDetailsView ()


@end

@implementation StoreDetailsView

- (IBAction)wishlistButtonClicked:(id)sender {
    if (_didSelectFollowButton) {
        _didSelectFollowButton(self, sender);
    }
}
- (IBAction)shareButtonClicked:(id)sender {
    if (_didSelectShareButton) {
        _didSelectShareButton(self, sender);
    }
}
- (IBAction)callButtonClicked:(id)sender {
    if (_didSelectCallButton) {
        _didSelectCallButton(self, sender);
    }
}


- (void)setupImageURL:(NSString*)urlString{
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    
    [_storeImageView setImageWithURLRequest:request
                          placeholderImage:nil
                              failureImage:nil
                          progressViewSize:CGSizeMake(_storeImageView.frame.size.width - 16, 10)
                         progressViewStile:UIProgressViewStyleDefault
                         progressTintColor:[UIColor colorWithRed:136/255.0f green:173/255.0f blue:230/255.0f alpha:1]
                            trackTintColor:[UIColor whiteColor]
                                sizePolicy:UNImageSizePolicyScaleAspectFill
                               cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       NSLog(@"Image Loaded");
                                       
                                       NSLog(@"%@", NSStringFromCGSize(image.size));
                                       [self setNeedsUpdateConstraints];
                                       [self setNeedsLayout];
                                       
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog(@"Image Failed");
                                       
                                   }
                                  progress:^(NSURLRequest *request, NSHTTPURLResponse *response, float progress) {
                                      
                                  }];
}


- (void)setStoreDict:(NSDictionary *)storeDict{
    
    _storeDict = storeDict;
    
    
    NSDictionary* imagesDict = [storeDict safeDictionaryObjectForKey:@"image"];
    
    NSString* mainImageURL = @"";
    if (IS_IPHONE_6 || IS_IPHONE_6P) {
        mainImageURL = [imagesDict safeStringObjectForKey:@"scale450"];
    }else{
        mainImageURL = [imagesDict safeStringObjectForKey:@"scale300"];
    }
    
    [self setupImageURL:mainImageURL];
    
    _descriptionLabel.text = [storeDict safeStringObjectForKey:@"category"];
    _nameLabel.text = [storeDict safeStringObjectForKey:@"street"];
    
}

@end
