//
//  ReadGetStartedViewController.m
//  MainAndMeios7
//
//  Created by Alexanedr on 12/7/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "ReadGetStartedViewController.h"
#import "hipmob/HMService.h"
#import "AppDelegate.h"

@interface ReadGetStartedViewController ()

@end

@implementation ReadGetStartedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didSwipe:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)getStartedButtonClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)chatNowButtonClicked:(id)sender {
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

        // open a chat view
        [[HMService sharedService] openChatWithPush:self withSetup:^(HMContentChatViewController * controller){
            // set the title of the chat window
            controller.title = @"Chat with an Operator";
            [self.navigationController setNavigationBarHidden:NO animated:NO];

            //controller.navigationBar.barTintColor = [UIColor redColor];
            
            //controller.chatView.sentTextColor = [UIColor redColor];
            
            //controller.chatView.sendMedia.hidden = YES;
            
            //[controller.chatView setCustomData:@"Timestamp" forKey:@"Joined"];
            //[controller.chatView setCustomData:@"$100K" forKey:@"Budget"];
            
        } forApp:APPID];
}

@end
