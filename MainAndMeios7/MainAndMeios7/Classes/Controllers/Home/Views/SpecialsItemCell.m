//
//  SpecialsItemCell.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 16.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SpecialsItemCell.h"

@interface SpecialsItemCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *coverButton;

@property (strong, nonatomic) CKCampaign* campaign;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) UIGestureRecognizerState gestureState;

@property (nonatomic,strong) UISwipeGestureRecognizer *swipeGesture;

@end

@implementation SpecialsItemCell

- (void)awakeFromNib{
    [super awakeFromNib];
    //self.webView.scalesPageToFit = YES;
    //self.webView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.webView.scrollView.clipsToBounds = YES;
    self.webView.scrollView.maximumZoomScale = 0.7; // set as you want.
    self.webView.scrollView.minimumZoomScale = 0.3; // set as you want.
    
    self.coverButton.hidden = YES;
    self.coverView.hidden = YES;

    //_webView.scrollView.delegate = self;
    
    //UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:_webView action:@selector(handleSingleTap:)];
    
     //self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:_webView action:@selector(handleSwipe:)];
    //_swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    //_swipeGesture.delegate = self;
    
    //singleTap.delegate = self;
    
    //UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:_webView action:@selector(handleLongPress:)];
    //longPress.numberOfTouchesRequired = 1;
    
    //longPress.delegate = self;
    
//    swip.delegate = self;

}

- (void)handleSwipe:(UIGestureRecognizer *)gestureRecognizer{

}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer{
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    
    if (gestureRecognizer == _swipeGesture) {
        
    }
    
    if (touch.tapCount ==2) {
        self.timer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(handleSingleTap:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        self.gestureState = UIGestureRecognizerStateBegan;
        return YES;
    }
    else if (touch.tapCount ==1 && self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    self.gestureState = gestureRecognizer.state;
    return YES;
}

// Handler will be called from timer
- (void)handleSingleTap:(UITapGestureRecognizer*)sender {
   // if (self.gestureState==UIGestureRecognizerStateRecognized) {
        if (_didClickCoverButton) {
            _didClickCoverButton(self, nil, _campaign);
        }
   // }
}




- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender.contentOffset.x != 0) {
        CGPoint offset = sender.contentOffset;
        offset.x = 0;
        sender.contentOffset = offset;
    }
}

- (void)setupCampaign:(CKCampaign*)campaign{
   
    _campaign = campaign;
    
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
   webView.scrollView.maximumZoomScale = 1; // set as you want.
    webView.scrollView.minimumZoomScale = 0.3; // set as you want.
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//     //   [self zoomToFit];
//    });
    
    UIScrollView *scroll=[self.webView scrollView];
    [scroll setZoomScale:0.76 animated:NO];

    
    
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

- (IBAction)didClickCoverButton:(id)sender {
    if (_didClickCoverButton) {
        _didClickCoverButton(self, sender, _campaign);
    }
}


@end
