//
//  HomeCoverView.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 4/23/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "HomeCoverView.h"


@interface HomeCoverView()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;

@property (strong, nonatomic) UIVisualEffectView *blurEffectView;

@end


@implementation HomeCoverView

- (void)awakeFromNib{
    [super awakeFromNib];
    // Init code
    
    _webView.scrollView.scrollEnabled = YES;
    //_webView.scrollView.ver
    _scrollView.bounces = NO;
    
    _webView.scrollView.maximumZoomScale = 2; // set as you want.
    _webView.scrollView.minimumZoomScale = 0.3; // set as you want.

    //[_webView.scrollView setZoomScale:0.86 animated:NO];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurEffectView.alpha = 0.5;
        [_blurEffectView setFrame:self.bounds];
        [self addSubview:_blurEffectView];
        [self sendSubviewToBack:_blurEffectView];
    }
}



- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height);
 
    self.spinnerView.center = self.scrollView.center;
    
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
    
    [self.spinnerView startAnimating];
}


- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //     //   [self zoomToFit];
    //    });

    
    [self.spinnerView stopAnimating];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"Webview request %@ failed to load with error: %@", webView.request, error);
    
    [self.spinnerView stopAnimating];

}


//scrolling ends
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //find the page number you are on
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"Scrolling - You are now on page %i",page);
    
    if (page == 1) {
        if (_didFinishViewing){
            _didFinishViewing(self);
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender == (UIScrollView *)_webView) {
        if (sender.contentOffset.x != 0) {
            CGPoint offset = sender.contentOffset;
            offset.x = 0;
            sender.contentOffset = offset;
        }

    }
}
////dragging ends, please switch off paging to listen for this event
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
//                     withVelocity:(CGPoint)velocity
//              targetContentOffset:(inout CGPoint *) targetContentOffset{
//    
//    //find the page number you are on
//    CGFloat pageWidth = scrollView.frame.size.width;
//    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    
//    if (scrollView.contentOffset.x > pageWidth / 2) {
//        [scrollView setContentOffset:CGPointMake(pageWidth, 0) animated:YES];
//    }else{
//        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    }
//    
//    NSLog(@"Dragging - You are now on page %i",page);
//    
//}

@end
