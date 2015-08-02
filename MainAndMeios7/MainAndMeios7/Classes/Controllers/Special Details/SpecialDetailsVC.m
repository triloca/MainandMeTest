//
//  SpecialDetailsVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 11.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SpecialDetailsVC.h"
#import "CustomTitleView.h"

#import "ShareView.h"
@import Social;
#import "PinterestManager.h"
#import "UIImage+Scaling.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "FacebookSDK/FacebookSDK.h"

@interface SpecialDetailsVC ()
<MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) ShareView* shareView;
@property (strong, nonatomic) NSLayoutConstraint* bottomConstraint;
@property (strong, nonatomic) UIDocumentInteractionController *docController;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SpecialDetailsVC

#pragma mark - Init



#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak SpecialDetailsVC* wSelf = self;
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"SPECIAL DETAIL" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        [[LayoutManager shared] showHomeControllerAnimated:YES];
        [wSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:@"No thanks" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
    deleteButton.backgroundColor = [UIColor clearColor];
    deleteButton.frame = CGRectMake(0, 0, 80, 40);
    deleteButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    //deleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [deleteButton addTarget:self action:@selector(settingsPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *delete  = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    
//    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithTitle:@"No thanks"
//                                                        style:UIBarButtonItemStylePlain
//                                                       target:self
//                                                       action:@selector(settingsPressed)];
    
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

//    [self onSharingButton:nil];
//    
//    return;
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            [[ProximityKitManager shared] addDeletedCompaign:_campaign];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
                                           title:@"Are you sure you want to delete this offer?\nDeleted offers are longer visible"
                                         message:nil
                               cancelButtonTitle:@"Delete"
                               otherButtonTitles:@"Keep", nil];

    
    //[[ProximityKitManager shared] deleteCompaign:_campaign];
    //[self.navigationController popViewControllerAnimated:YES];
}


//////
#pragma mark - Share

- (IBAction)onSharingButton:(id)sender {
    
    [self showShare:YES animated:YES];
}


- (void)showShare:(BOOL)value animated:(BOOL)animated{
    
    
    if (self.shareView == nil) {
        
        self.shareView = [ShareView loadViewFromXIB];
        self.shareView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.shareView];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shareView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shareView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.shareView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:self.shareView.frame.size.height];
        
        //        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shareView
        //                                                           attribute:NSLayoutAttributeHeight
        //                                                           relatedBy:NSLayoutRelationEqual
        //                                                              toItem:nil
        //                                                           attribute:NSLayoutAttributeNotAnAttribute
        //                                                          multiplier:1.0
        //                                                            constant:195]];
        
        //        [self.shareView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[shareView(==195)]"
        //                                                                       options:0
        //                                                                       metrics:nil
        //                                                                         views:NSDictionaryOfVariableBindings(self.shareView)]];
        [self.view addConstraint:_bottomConstraint];
        
        [self.view layoutIfNeeded];
        
        __weak SpecialDetailsVC* wSelf = self;
        
        self.shareView.didClickCancelButton = ^(ShareView* view, UIButton* button){
            [wSelf showShare:NO animated:YES];
        };
        
        self.shareView.didClickShareButton = ^(ShareView* view, UIButton* button){
            switch (button.tag) {
                case 1:{
                    
                    [wSelf showSpinnerWithName:@""];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareMessage];
                    });
                    
                }
                    break;
                case 2:{
                    
                    [wSelf showSpinnerWithName:@""];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareMail];
                    });
                }
                    break;
                case 3:{
                    
                    //[wSelf showSpinnerWithName:@""];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareFacebook];
                    });
                }
                    break;
                case 4:{
                    [wSelf showSpinnerWithName:@""];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareTwitter];
                    });
                }
                    break;
                case 5:
                    [wSelf sharePinterest];
                    break;
                case 6:{
                    
                    [wSelf showSpinnerWithName:@""];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareInstagrem];
                    });
                }
                    break;
                    
                default:
                    break;
            }
        };
        
    }
    
    [self.view bringSubviewToFront:self.shareView];
    
    
    [UIView animateWithDuration:animated ? 0.3 : 0
                     animations:^{
                         
                         if (value) {
                             _bottomConstraint.constant = 0;
                             //self.bottomShareView.hidden = YES;
                         }else{
                             _bottomConstraint.constant = self.shareView.frame.size.height;
                             //self.bottomShareView.hidden = NO;
                         }
                         
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}


#pragma mark - Share Actions

- (void)shareMessage{
    //[self prepareForShare];
    
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            controller.messageComposeDelegate = self;
            
            NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this event I found on Main&Me:\n"];
            
            
            NSString* urlString = [_campaign.content.attributes safeStringObjectForKey:@"image_url"];
            [bodyString appendString:urlString];
            
            NSString* imageURL = urlString;
            NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            if (photoData) {
                [controller addAttachmentData:photoData typeIdentifier:@"public.data" filename:@"image.png"];
            }
            
            controller.body = bodyString;
            
            [self presentViewController:controller animated:YES completion:^{}];
        } else {
            [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via SMS"];
        }
    }
    
    [self hideSpinnerWithName:@""];
    
}

- (void)shareMail{
    
    if ([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this event I found on Main&Me:\n"];
        
        NSString* urlString = [_campaign.content.attributes safeStringObjectForKey:@"image_url"];
        [bodyString appendString:urlString];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data) {
                                       [controller addAttachmentData:data mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"photo.png"]];
                                   }
                                   
                                   [controller setSubject:@"Local sponsor on Main&Me"];
                                   [controller setMessageBody:[NSString stringWithFormat:@"%@", bodyString] isHTML:NO];
                                   
                                   [self presentViewController:controller animated:YES completion:^{}];
                                   
                                   [self hideSpinnerWithName:@""];
                               }];
        
    } else {
        [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via Email"];
    }
    
}

- (void)shareTwitter{
    
    // No Twitter Account
    // There are no Twitter acconts configured. You can add or create a Twitter account in Settings
    // Cancel Settings
    
    // Confirm that a Twitter account exists
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        
        
        // Create a compose view controller for the service type Twitter
        __block SLComposeViewController *twController = ({
            twController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            
            
            [twController setCompletionHandler:^(SLComposeViewControllerResult result){
                
                [self showShare:NO animated:NO];
                
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Compose Result: Post Cancelled");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Compose Result: Post Done");
                    default:
                        break;
                }}];
            
            twController;
        });
        
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this event I found on Main&Me:\n"];
        
        NSString* urlString = [_campaign.content.attributes safeStringObjectForKey:@"image_url"];
        [bodyString appendString:urlString];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   UIImage* image = [UIImage imageWithData:data];
                                   
                                   if (image) {
                                       [twController addImage:image];
                                   }
                                   //}
                                   
                                   
                                   [twController addURL:[NSURL URLWithString:@"http://www.mainandme.com"]];
                                   
                                   // Set the text of the tweet
                                   [twController setInitialText:bodyString];
                                   // Set the completion handler to check the result of the post.
                                   
                                   // Display the tweet sheet to the user
                                   [self presentViewController:twController animated:YES completion:nil];
                                   
                                   //Memory Management
                                   twController = nil;
                                   [self hideSpinnerWithName:@""];
                               }];
    }
    
    else
    {
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView.cancelButtonIndex != buttonIndex) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }
                                               title:@"No Twitter Account"
                                             message:@"There are no Twitter acconts configured. You can add or create a Twitter account in Settings"
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Settings", nil];
    }
    
}

- (void)shareFacebook{
    // No Facebook Account
    // There are no Facebook accont configured. You can add or create a Facebook account in Settings
    // Cancel Settings
    
    [self shareButtonClicked:nil];
    
    return;
    
    
    SLComposeViewController * fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            
            [self hideSpinnerWithName:@""];
            [self showShare:NO animated:NO];
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted.");
                }
                    break;
            }};
        
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this event I found on Main&Me:\n"];
        
        NSString* urlString = [_campaign.content.attributes safeStringObjectForKey:@"image_url"];
        [bodyString appendString:urlString];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   UIImage* image = [UIImage imageWithData:data];
                                   
                                   if (image) {
                                       [fbController addImage:image];
                                   }
                                   
                                   [fbController setInitialText:bodyString];
                                   [fbController addURL:[NSURL URLWithString:@"http://www.mainandme.com"]];
                                   [fbController setCompletionHandler:completionHandler];
                                   [self presentViewController:fbController animated:YES completion:nil];
                                   
                                   [self hideSpinnerWithName:@""];
                               }];
        
    }else{
        
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView.cancelButtonIndex != buttonIndex) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }
                                               title:@"No Facebook Account"
                                             message:@"There are no Facebook acconts configured. You can add or create a Facebook account in Settings"
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Settings", nil];
    }
    
    
}

- (void)sharePinterest{
    
    if ([[PinterestManager shared].pinterest canPinWithSDK]) {
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this event I found on Main&Me:\n"];
        
        NSString* urlString = [_campaign.content.attributes safeStringObjectForKey:@"image_url"];
        
        [bodyString appendString:urlString];
        [bodyString appendString:@".\n"];
        
        
        NSString* imageURLStr = urlString;
        
        //}
        
        
        NSURL* imageURL = [NSURL URLWithString:imageURLStr];
        NSURL* sourceURL = [NSURL URLWithString:@"http://www.mainandme.com"];
        
        [[PinterestManager shared].pinterest createPinWithImageURL:imageURL
                                                         sourceURL:sourceURL
                                                       description:bodyString];
        
    }else{
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"Can't share pin"
                                             message:@"Please install last version of Pinterest app"
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];
        
    }
}

- (void)shareInstagrem{
    
    
    NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this event I found on Main&Me"];
    
    NSString* urlString = [_campaign.content.attributes safeStringObjectForKey:@"image_url"];
    //[bodyString appendString:urlString];
    //[bodyString appendString:urlString];
    
    NSString* imageURL = urlString;
    NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    UIImage* image = [UIImage imageWithData:photoData];
    
    
    image = [image imageScaledToSize:CGSizeMake(640, 640)];
    [NSDictionary dictionaryWithObject:@"Your AppName" forKey:@"InstagramCaption"];
    [self shareImageOnInstagram:image
                     annotation:@{@"InstagramCaption" : bodyString}];
    
}


-(void)shareImageOnInstagram:(UIImage*)shareImage annotation:(NSDictionary*)annotation
{
    //It is important that image must be larger than 612x612 size if not resize it.
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"Image.igo"];
        NSData *imageData=UIImagePNGRepresentation(shareImage);
        [imageData writeToFile:saveImagePath atomically:YES];
        
        NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
        
        self.docController = [[UIDocumentInteractionController alloc]init];
        _docController.delegate=self;
        _docController.UTI=@"com.instagram.exclusivegram";
        
        _docController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:@"Image Taken via @App",@"InstagramCaption", nil];
        
        [_docController setURL:imageURL];
        [_docController setAnnotation:annotation];
        
        //[docController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];  //Here try which one is suitable for u to present the doc Controller. if crash occurs
        
        [_docController presentOpenInMenuFromRect:self.view.frame
                                           inView:self.view
                                         animated: YES ];
    }else{
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"Can't share Item"
                                             message:@"Please install last version of Instagram app"
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];
        
    }
    
    [self hideSpinnerWithName:@""];
}

#pragma Documents Delegate

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}


#pragma mark -  FB
- (IBAction)shareButtonClicked:(id)sender
{
    
    
    NSString* urlString = [_campaign.content.attributes safeStringObjectForKey:@"image_url"];
    
    // if the session is closed, then we open it here, and establish a handler for state changes
    
    [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session,FBSessionState state, NSError *error)
     {
         if (error)
         {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         }
         else if(session.isOpen)
         {
             NSDictionary *params = @{
                                      @"name" :@"Found this special on Main&Me",
                                      //@"caption" : @".",
                                      //@"description" :@"",
                                      //@"picture" : @"",
                                      @"link" : urlString,
                                      // @"message":
                                      };
             
             // Invoke the dialog
             [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                                    parameters:params
                                                       handler:
              ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                  if (error) {
                      NSLog(@"Error publishing story.");
                  } else {
                      if (result == FBWebDialogResultDialogNotCompleted) {
                          NSLog(@"User canceled story publishing.");
                      } else {
                          NSLog(@"Story published.");
                      }
                  }}];
         }
         
     }];
    
}


#pragma mark - MFMessageCompose Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled: {
            NSLog(@"Cancelled");
        }
            break;
        case MessageComposeResultFailed: {
            [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Can't Share SMS"];
        }
            break;
        case MessageComposeResultSent:
            [[AlertManager shared] showOkAlertWithTitle:@"Success" message:@"Shared via SMS"];
            break;
        default:
            break;
    }
    
    [self showShare:NO animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled: {
            NSLog(@"Cancelled");
        }
            break;
        case MFMailComposeResultFailed: {
            [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Can't Share via Email"];
        }
            break;
        case MFMailComposeResultSent:
            [[AlertManager shared] showOkAlertWithTitle:@"Success" message:@"Shared via Email"];
            break;
        default:
            break;
    }
    
    
    [self showShare:NO animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}


//////

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
