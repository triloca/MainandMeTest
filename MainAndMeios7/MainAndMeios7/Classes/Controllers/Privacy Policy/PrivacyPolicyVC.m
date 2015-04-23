//
//  PrivacyPolicyVC.m
//  MainAndMeios7
//
//  Created by Max on 11/6/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PrivacyPolicyVC.h"
#import "CustomTitleView.h"

@interface PrivacyPolicyVC ()
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PrivacyPolicyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // configure top view controller
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"PRIVACY POLICY" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
    }];
    
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"html"]isDirectory:NO]]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
   [_textView setFont:[UIFont fontWithName:@"DINBek-Regular" size:15]];
    _textView.textContainerInset = UIEdgeInsetsMake(20, 15, 45, 15);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

@end
