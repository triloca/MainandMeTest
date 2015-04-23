//
//  SpecialCell.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SpecialCell.h"

@interface SpecialCell()

@property (strong, nonatomic) NSDictionary *product;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
@implementation SpecialCell

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
    
    __weak SpecialCell *wself = self;
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



- (void)setupCampaign:(CKCampaign*)campaign{

    if (campaign.content.body.length > 0) {
        NSMutableString* my_string = [NSMutableString stringWithString:campaign.content.body];

        // NSString* temp  = [my_string stringByReplacingOccurrencesOfString:@"width=\"300\"" withString:@"width=\"300\""];

        [self.webView loadHTMLString:my_string baseURL:nil];
    }

    //_messageLabel.text = _campaign.content.alertMessage;
}


- (void) setItemURL: (NSURL *) url {
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    webView.scrollView.maximumZoomScale = 2; // set as you want.
    webView.scrollView.minimumZoomScale = 0.3; // set as you want.

    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //     //   [self zoomToFit];
    //    });

}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"Webview request %@ failed to load with error: %@", webView.request, error);
}


-(void)zoomToFit
{

    if ([self.webView respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scroll=[self.webView scrollView];

        float zoom=self.webView.bounds.size.width/scroll.contentSize.width;
        //zoom *= 0.98;
        [scroll setZoomScale:zoom animated:NO];
    }
}

@end
