//
//  ProductDetailsVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 11.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ProductDetailsVC.h"
#import "CustomTitleView.h"
#import "AddToWishlistRequest.h"
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ProductDetailsVC ()
<UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) NSString *phone;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (strong, nonatomic) CAGradientLayer *gradient;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@end

@implementation ProductDetailsVC

- (id) initWithProduct: (NSDictionary *) product {
    if (self = [super initWithNibName:@"ProductDetailsVC" bundle:nil]) {
        self.product = product;
    }
    return self;
}

- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidLayoutSubviews {
    if (self.gradient)
        return;
    
    self.gradient = [CAGradientLayer layer];
    _gradient.frame = CGRectMake(0, 0, _gradientView.frame.size.width, _gradientView.frame.size.height);
    _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.8] CGColor], nil];
    
    [_gradientView.layer insertSublayer:_gradient atIndex:0];
    [self.view sendSubviewToBack:_gradientView];
    [self.view sendSubviewToBack:_imageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phone = [_product safeObjectForKey:@"phone"];
    if (![_phone isValidate])
        self.phone = [_product safeObjectForKey:@"phone_number"];
    if ([_phone isKindOfClass:[NSNull class]] || ![_phone isValidate]) {
        self.phone = nil;
        self.phoneButton.hidden = YES;
    }

    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"ITEM DETAIL" dropDownIndicator:NO clickCallback:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_map_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(mapAction:)];
    
    _titleLabel.text = [_product safeStringObjectForKey:@"name"];
    _descriptionLabel.text = [_product safeStringObjectForKey:@"description"];
    //_descriptionLabel.text = @"sdkjsdfksdbkjf dslhbdsk;bvskd dsfg dfsjgvfds;bg;fdskb dgdhlfsv;ksdf vdib";
    
    NSString* price = [_product safeStringObjectForKey:@"price"];
    if (price.length == 0) {
        price = @"---";
    }
    _priceLabel.textColor = kAppColorGreen;
    _priceLabel.text = price;

    NSDictionary* imagesDict = [_product safeDictionaryObjectForKey:@"image"];
    
    NSString* mainImageURL = @"";
//    if (IS_IPHONE_6 || IS_IPHONE_6P) {
//        mainImageURL = [imagesDict safeStringObjectForKey:@"scale450"];
//    }else{
//        mainImageURL = [imagesDict safeStringObjectForKey:@"scale300"];
//    }
    
    mainImageURL = [imagesDict safeStringObjectForKey:@"full"];

    [self setupImageURL:mainImageURL];
}



- (void)setupImageURL:(NSString*)urlString{
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [_spinnerView startAnimating];
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
                                       NSLog(@"Image Loaded");
                                       
                                       NSLog(@"%@", NSStringFromCGSize(image.size));
                                       
                                       [_spinnerView stopAnimating];
                                       
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog(@"Image Failed");
                                       [_spinnerView stopAnimating];
                                   }
                                  progress:^(NSURLRequest *request, NSHTTPURLResponse *response, float progress) {
                                      
                                  }];

}



- (IBAction)callAction:(id)sender {
    NSString *telLink = [NSString stringWithFormat:@"tel://%@", _phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telLink]];
}

- (IBAction)shareAction:(id)sender {
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self
                                                         cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Email", @"SMS", nil];
    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    
    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    @try {
        if (buttonIndex == 4) {
            NSLog(@"Cancel");
        }
        else if (buttonIndex == 0) {
            [self fBbuttonClicked];
        }
        else if (buttonIndex == 1) {
            [self twitterButtonClicked];
        }
        else if (buttonIndex == 2) {
            [self sendMail];
        }
        else if (buttonIndex == 3) {
            [self sendSms];
        }
        
    }
    @catch (NSException *exception) {
        [[AlertManager shared] showOkAlertWithTitle:@"Share Exception"];
    }
}

// Mail
- (void)sendMail {
    
    if ([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Recommendation for MainAndMe"];
        [controller setMessageBody:[NSString stringWithFormat:@"%@", [_product safeStringObjectForKey:@"name"]] isHTML:NO];
        
        if (_imageView.image) {
            NSData *photoData = UIImageJPEGRepresentation(_imageView.image, 1);
            [controller addAttachmentData:photoData mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"photo.png"]];
        }
        
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
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Privat Methods

- (void)sendSms{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            controller.body = [NSString stringWithFormat:@"%@", [_product safeStringObjectForKey:@"name"]];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:^{}];
        } else {
            [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via SMS"];
        }
    }
}



// TW

- (void)twitterButtonClicked{
    
    [[AlertManager shared] showOkAlertWithTitle:@"This functionality not tesed yet"];
    
    return;
    [self loginToTwitter];
}

- (void)loginToTwitter{
    
    
    [[TwitterManager shared] loginVCPresentation:^(UIViewController *twitterLoginVC) {
        [self presentViewController:twitterLoginVC animated:YES completion:^{}];
    }
                                         success:^(UIViewController *twitterLoginVC, FHSToken *token) {
                                             [self postTweet];
                                         }
                                         failure:^(UIViewController *twitterLoginVC, NSError *error) {
                                             
                                             [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                 message:@"Login failed"];
                                         }
                                          cancel:^(UIViewController *twitterLoginVC) {
                                              
                                          }
                                 alreadyLoggedIn:^(UIViewController *twitterLoginVC, FHSToken *token) {
                                     [self postTweet];
                                 }];
    
    
}


- (void)postTweet{
    
    NSString* name = [_product safeStringObjectForKey:@"name"];
    name = [name stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
    NSString* text = [NSString stringWithFormat:@"Main And Me app\n%@", name];
    
    UIImage* image = _imageView.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    
    [[FHSTwitterEngine sharedEngine]postTweet:text withImageData:imageData];
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
    
    if (error != nil) {
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
    
    NSString* imageUrl = [[_product safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
    NSString* description = [NSString stringWithFormat:@"%@\n %@",
                             [_product safeStringObjectForKey:@"name"],
                             [_product safeStringObjectForKey:@"description"]];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"254708664663458", @"app_id",
                                   @"http://mainandme-staging-s.herokuapp.com", @"link",
                                   imageUrl, @"picture",
                                   @"Main And Me", @"name",
                                   @"Product", @"caption",
                                   description, @"description",
                                   @"Main And Me application",  @"message",
                                   nil];
    
    
    [self showSpinnerWithName:@"ProductDetailViewController"];
    
    //Post to wall.
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", facebookId]
                                 parameters:params HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         [self hideSpinnerWithName:@"ProductDetailViewController"];
         
         if (error)
         {
             [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
         }
         else
         {
             [[AlertManager shared] showOkAlertWithTitle:@"Sucess" message:@"Posted to Facebook successfuly"];
         }
         
     }];
    
}



- (IBAction)wishlistAction:(id)sender {
//    AddToWishlistRequest *request = [[AddToWishlistRequest alloc] init];
//    request.productId = [_product safeObjectForKey:@"id"];
//    request.wishlistId = @(1);
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        //Success
//        NSLog(@"Success");
//    } failure:^(id _request, NSError *error) {
//        //Failed
//    }];

    [[AlertManager shared] showOkAlertWithTitle:@"This functionality is not implemented yet"];
}

- (void) mapAction: (id) sender {
    [[AlertManager shared] showOkAlertWithTitle:@"This functionality is not implemented yet"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
