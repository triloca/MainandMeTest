//
//  SponsoredByVC.m
//  MainAndMeios7
//
//  Created by Max on 11/6/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SponsoredByVC.h"
#import "CustomTitleView.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"

#import "ShareView.h"
@import Social;
#import "PinterestManager.h"
#import "UIImage+Scaling.h"


@interface SponsoredByVC ()
<UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;

@property (strong, nonatomic) ShareView* shareView;
@property (strong, nonatomic) NSLayoutConstraint* bottomConstraint;
@property (strong, nonatomic) UIDocumentInteractionController *docController;

@property (strong, nonatomic) CKCampaign* campaign;

@end

@implementation SponsoredByVC



#pragma mark _______________________ Class Methods _________________________

#pragma mark ____________________________ Init _____________________________

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // configure top view controller
    
    if (_wasPushed) {
        UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:[UIImage imageNamed:@"nav_back_button.png"] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, 0, 40, 40);
        [menuButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = anchorLeftButton;
    }else{
        UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, 0, 40, 40);
        [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = anchorLeftButton;
    }
    __weak SponsoredByVC* wSelf = self;
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"Sponsored by" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        [[LayoutManager shared] showHomeControllerAnimated:YES];
        [wSelf.navigationController popToRootViewControllerAnimated:YES];
    }];

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_det_share_btn@2x.png"]
                                                                landscapeImagePhone:nil
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(shareAction)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupCampaign:[[ProximityKitManager shared].activeCampaigns firstObject]];
    
    for (CKCampaign* c in [ProximityKitManager shared].activeCampaigns) {
        NSLog(@"%@", c.content);
    }
}


#pragma mark _______________________ Buttons Action ________________________


- (void)shareAction {
    
    [self onSharingButton:nil];
    
//    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share"
//                                                                  delegate:self
//                                                         cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Email", @"SMS", nil];
//    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//    
//    
//    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}


#pragma mark _______________________ Privat Methods(view)___________________

- (void)backButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

#pragma mark _______________________ Privat Methods ________________________

- (void)setupCampaign:(CKCampaign*)campaign{
    
    _campaign = campaign;
    
    if (campaign.content.body.length > 0) {
        NSMutableString* my_string = [NSMutableString stringWithString:campaign.content.body];
        
        // NSString* temp  = [my_string stringByReplacingOccurrencesOfString:@"width=\"300\"" withString:@"width=\"300\""];
        
        [self.webView loadHTMLString:my_string baseURL:nil];
    }
    
    //_messageLabel.text = _campaign.content.alertMessage;
}

//! FB
- (void)fBbuttonClicked{
    [self openFBSession];
}

- (void)openFBSession {
    
    if (FBSession.activeSession.isOpen) {
        [self loadMeFacebook];
    } else {
        
        if (![ReachabilityManager isReachable]) {
            [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
            return;
        }
        
        NSArray* permissions = [[NSArray alloc] initWithObjects:@"publish_stream",@"email", nil];
        [FBSession.activeSession closeAndClearTokenInformation];
        [self showSpinnerWithName:@"ProductDetailViewController"];
        [FBSession openActiveSessionWithPublishPermissions:permissions
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             [self hideSpinnerWithName:@"ProductDetailViewController"];
                                             [self sessionStateChanged:session state:status error:error];
                                         }];
        
    }
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            [self loadMeFacebook];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error != nil && error.code != 2) {
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
    }
}


- (void)loadMeFacebook {
    
    [self showSpinnerWithName:@"ProductDetailViewController"];
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection, id <FBGraphUser> user, NSError *error) {
         [self hideSpinnerWithName:@"ProductDetailViewController"];
         if (!error) {
             
             [self postToWall:user.objectID];
             
         }else{
             [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
         }
     }];
}

- (void)postToWall:(NSString*)facebookId{
    
//    NSString* imageUrl = [[_storeDict safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
//    NSString* description = [NSString stringWithFormat:@"%@\n %@",
//                             [_storeDict safeStringObjectForKey:@"name"],
//                             [_storeDict safeStringObjectForKey:@"description"]];
//    
//    NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[_storeDict safeNumberObjectForKey:@"id"] stringValue]];
//    
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"254708664663458", @"app_id",
//                                   urlString, @"link",
//                                   imageUrl, @"picture",
//                                   [_storeDict safeStringObjectForKey:@"name"], @"name",
//                                   @"Store", @"caption",
//                                   description, @"description",
//                                   @"I found this local gem on Main&Me",  @"message",
//                                   nil];
//    
//    
//    [self showSpinnerWithName:@"ProductDetailViewController"];
//    
//    //Post to wall.
//    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", facebookId]
//                                 parameters:params HTTPMethod:@"POST"
//                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
//     {
//         [self hideSpinnerWithName:@"ProductDetailViewController"];
//         
//         if (error)
//         {
//             [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
//         }
//         else
//         {
//             [[AlertManager shared] showOkAlertWithTitle:@"Success" message:@"Posted to Facebook successfuly"];
//         }
//         
//     }];
    
}

// Mail
- (void)sendMail {
    
    if ([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"A friend shared a \"local find\" on MainAndMe"];
        
        
        
//        NSString* bodyString = [_storeDict safeStringObjectForKey:@"name"];
//        
//        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[_storeDict safeNumberObjectForKey:@"id"] stringValue]];
//        bodyString = [NSString stringWithFormat:@"You might like this gem I found in your neck of the woods:\n%@\n%@", bodyString, urlString];
//        [controller setMessageBody:[NSString stringWithFormat:@"%@", bodyString] isHTML:NO];
//        
//        if (_storeDetailsView.storeImageView.image) {
//            NSData *photoData = UIImageJPEGRepresentation(_storeDetailsView.storeImageView.image, 1);
//            [controller addAttachmentData:photoData mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"photo.png"]];
//        }
        
        //        NSString* email = [UserDefaultsManager shared].email;
        //        if (email && [email isKindOfClass:[NSString class]]) {
        //            NSArray *toRecipients = [NSArray arrayWithObjects:email, nil];
        //            [controller setToRecipients:toRecipients];
        //
        //        }
        [self presentViewController:controller animated:YES completion:^{}];
        
    } else {
        [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via Email"];
    }
    
}


- (void)sendSms{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            
//            
//            NSString* bodyString = @"Found this local gem on Main&Me:";
//            bodyString = [NSString stringWithFormat:@"%@\n%@", bodyString, [_storeDict safeStringObjectForKey:@"name"]];
//            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[_storeDict safeNumberObjectForKey:@"id"] stringValue]];
//            bodyString = [NSString stringWithFormat:@"%@\n%@", bodyString, urlString];
//            controller.body = bodyString;
            
//            if (_storeDetailsView.storeImageView.image) {
//                NSData *photoData = UIImageJPEGRepresentation(_storeDetailsView.storeImageView.image, 1);
//                //[controller addAttachmentData:photoData typeIdentifier:(NSString *)kUTTypePNG filename:@"photo.png"];
//                [controller addAttachmentData:photoData typeIdentifier:@"public.data" filename:@"image.png"];
//            }
            
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:^{}];
        } else {
            [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via SMS"];
        }
    }
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
        
        __weak SponsoredByVC* wSelf = self;
        
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
                                      @"name" :@"Check out this local sponsor of Main&Me:",
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


#pragma mark - Share Actions

- (void)shareMessage{
    //[self prepareForShare];
    
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            controller.messageComposeDelegate = self;
            
            NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this local sponsor of Main&Me:\n"];
            
            
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
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this local sponsor of Main&Me:\n"];
        
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
        
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this local sponsor of Main&Me:\n"];
        
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
        
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this local sponsor of Main&Me:\n"];
        
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
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this local sponsor of Main&Me:\n"];
        
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
    
    
    NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this local sponsor of Main&Me"];
    
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



#pragma mark _______________________ Public Methods ________________________

#pragma mark _______________________ Delegates _____________________________

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        
        NSURL *url = request.URL;
        //[self openExternalURL:url];//Handle External URL here
        
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    
    return YES;
    
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

#pragma mark  UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    return;
    @try {
        if (buttonIndex == 4) {
            NSLog(@"Cancel");
        }
        else if (buttonIndex == 0) {
            [self fBbuttonClicked];
        }
        //        else if (buttonIndex == 1) {
        //            [self twitterButtonClicked];
        //        }
        else if (buttonIndex == 1) {
            [self sendMail];
        }
        else if (buttonIndex == 2) {
            [self sendSms];
        }
        
    }
    @catch (NSException *exception) {
        [[AlertManager shared] showOkAlertWithTitle:@"Share Exception"];
    }
}

#pragma mark _______________________ Notifications _________________________









/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
//        [[UIApplication sharedApplication] openURL:[request URL]];
//        return NO;
//    }
//    
//    return YES;
//}




@end
