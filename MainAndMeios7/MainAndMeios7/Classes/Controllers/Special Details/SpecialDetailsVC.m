//
//  SpecialDetailsVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 11.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SpecialDetailsVC.h"
#import "CustomTitleView.h"


@interface SpecialDetailsVC ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SpecialDetailsVC

#pragma mark - Init



#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"SPECIAL DETAIL" dropDownIndicator:NO clickCallback:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithTitle:@"Delete"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(settingsPressed)];
    
    self.navigationItem.rightBarButtonItem = delete;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
    
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark - Actions

- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)settingsPressed{

    [[ProximityKitManager shared] deleteCompaign:_campaign];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Privat Methods

- (void)loadData{
    [self setupCampaign:_campaign];
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
