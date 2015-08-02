//
//  ProductDetailsVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 11.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "MyPhotoDetailsVC.h"
#import "CustomTitleView.h"
#import "AddToWishlistRequest.h"
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "LoadStoreRequest.h"
#import "StoreMapViewController.h"
#import "WishlistPickerVC.h"
#import "ProductDetailsManager.h"
#import "StoreDetailsVC.h"
#import "NSString+Price.h"
#import "StoreNamePickerView.h"
#import "SearchRequest.h"
#import "SearchManager.h"

@interface MyPhotoDetailsVC ()
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

@property (strong, nonatomic) NSDictionary* storeDetails;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;
@property (weak, nonatomic) IBOutlet UILabel *storeLabel;

@property (weak, nonatomic) IBOutlet UIButton *callForPriceButton;

@property (weak, nonatomic) IBOutlet StoreNamePickerView *storeNamePickerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storePickerConstraint;

@end

@implementation MyPhotoDetailsVC

- (void)dealloc{

}

#pragma mark - Init


#pragma mark - View lifecycle
//
//- (void) viewDidLayoutSubviews {
//    if (self.gradient)
//        return;
//    
//    self.gradient = [CAGradientLayer layer];
//    _gradient.frame = CGRectMake(0, 0, _gradientView.frame.size.width, _gradientView.frame.size.height);
//    _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.8] CGColor], nil];
//    
//    [_gradientView.layer insertSublayer:_gradient atIndex:0];
//    [self.view sendSubviewToBack:_gradientView];
//    [self.view sendSubviewToBack:_imageView];
//    [self.view setNeedsLayout];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phone = nil;
    self.phoneButton.enabled = YES;

    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"My photo"
                                                         dropDownIndicator:NO
                                                             clickCallback:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_map_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(mapAction:)];
//    
    [self updateAddStoreButton];
    [self updateStoreName];
    
    
    _titleLabel.text = @"";
    _descriptionLabel.text = @"";
    
    NSString* price = @"Call for price";
    if (price.length == 0 || [price isEqualToString:@"0.0"]) {
        //price = @"Call for price";
        _callForPriceButton.hidden = NO;
    }else{
        _callForPriceButton.hidden = YES;
    }
    _priceLabel.textColor = kAppColorGreen;
    
    
    
    _priceLabel.text = @"Call for price";//[price priceString];
    
    //[self loadStoreInfoComletion:^{}];
    
    
//    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [self.view addGestureRecognizer:recognizer];
//    
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//    [self.view addGestureRecognizer:recognizer];

    __weak MyPhotoDetailsVC* wSelf = self;
    
    self.storeNamePickerView.onOkButton = ^(StoreNamePickerView* view, NSDictionary* store ,UIButton* button){
        wSelf.myPhoto.storeName = [store safeStringObjectForKey:@"name"];
        [wSelf updateAddStoreButton];
        [wSelf.myPhoto addToStore];
        [wSelf updateStoreName];
        [wSelf show:NO pickerAnimated:YES];
    };
    
    self.storeNamePickerView.onCancelButton = ^(StoreNamePickerView* view, UIButton* button){
        [wSelf show:NO pickerAnimated:YES];
    };
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    NSDictionary* imagesDict = [_product safeDictionaryObjectForKey:@"image"];
//    NSString* mainImageURL = @"";
//    mainImageURL = [imagesDict safeStringObjectForKey:@"full"];
    
    //[self setupImageURL:mainImageURL];
    [self setimagePath:[_myPhoto pathForLocalImage]];
}

- (void)setimagePath:(NSString*)path{
    
    if (!path) {
        return;
    }
    NSURL *localURL = [NSURL fileURLWithPath:path];
    
    if (!localURL) {
        return;
    }
    
    NSURLRequest* request = [NSURLRequest requestWithURL:localURL
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    [_spinnerView startAnimating];
    [self.imageView  setImageWithURLRequest:request
                           placeholderImage:nil
                               failureImage:nil
                           progressViewSize:CGSizeMake(_imageView.frame.size.width - 16, 10)
                              imageViewSize:_imageView.bounds.size//CGSizeMake(105, 105)
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
                                   progress:nil];
}


- (void)setupImageURL:(NSString*)urlString{
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    //NSLog([_imageView description]);
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

#pragma mark - Actions

- (void) backAction: (id) sender {
    [UIImageView clearMemoryImageCache];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)callButtonClicked:(id)sender {
    
    return;
    
    if ([_phone isKindOfClass:[NSNull class]] || ![_phone isValidate]) {

        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"A number has not been provided for this store yet"
                                             message:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        
    }else{
        
//        NSString* messageString = [NSString stringWithFormat:@"Call %@ at %@?", [_product safeStringObjectForKey:@"store_name"], _phone];
//        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (alertView.cancelButtonIndex != buttonIndex) {
//                [self callAction:nil];
//            }
//        }
//                                               title:messageString
//                                             message:nil
//                                   cancelButtonTitle:@"Cancel"
//                                   otherButtonTitles:@"Call", nil];

    }
}

- (IBAction)callAction:(id)sender {
    
//    NSString* phone = [_phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
//    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
//    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
//    
//    NSString *telLink = [NSString stringWithFormat:@"tel://%@", phone];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telLink]];
}

- (IBAction)shareAction:(id)sender {
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self
                                                         cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Email", @"SMS", nil];
    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    
    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}

- (IBAction)wishlistAction:(id)sender {
    
//    WishlistPickerVC *picker = [WishlistPickerVC loadFromXIB_Or_iPhone5_XIB];
//    picker.hideMyPhotos = YES;
//    picker.userId = [CommonManager shared].userId;
//    picker.onSelectWishlistCallback = ^(NSDictionary *dict) {
//        if (dict == nil) {
//            [[AlertManager shared] showOkAlertWithTitle:@"MAIN AND ME" message:@"Unable to load wishlists. Please try again later"];
//            return ;
//        } else {
//            __weak ProductDetailsVC *wself = self;
//            [self showSpinnerWithName:@"Loading"];
//            [ProductDetailsManager addToWishlist:dict[@"id"] productId:_product[@"id"] success:^() {
//                [[AlertManager shared] showOkAlertWithTitle:@"Product was added to wishlist successfully"];
//                [wself hideAllSpiners];
//            } failure:^(NSError *error, NSString *errorString) {
//                
//                if ([errorString isEqualToString:@"This product is already added to this wishlist."]) {
//                    errorString = @"You already added this item to this wish list";
//                }
//                [[AlertManager shared] showOkAlertWithTitle:errorString];
//                
//                
//                [wself hideAllSpiners];
//            } exception:^(NSString *exeptionString) {
//                [[AlertManager shared] showOkAlertWithTitle:@"Error occured while adding item to wishlist. Please try again later"];
//                [wself hideAllSpiners];
//            }];
////            AddToWishlistRequest *request = [[AddToWishlistRequest alloc] init];
////            request.wishlistId = dict[@"id"];
////            request.productId = _product[@"id"];
////            
////            __weak ProductDetailsVC *wself = self;
////            [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
////                [[AlertManager shared] showOkAlertWithTitle:@"Product was added to wishlist successfully"];
////                [wself hideAllSpiners];
////            } failure:^(id _request, NSError *error) {
////                [[AlertManager shared] showOkAlertWithTitle:@"Error occured while adding item to wishlist. Please try again later"];
////                [wself hideAllSpiners];
////            }];
//        }
//    };
//    
//    [self.navigationController pushViewController:picker animated:YES];
}


- (void)updateAddStoreButton{

    if (_myPhoto.storeName.length > 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add store?" style:UIBarButtonItemStyleBordered target:self action:@selector(addStoreButtonClicked:)];
    }
}


- (void)updateStoreName{
    
    if (_myPhoto.storeName.length > 0) {
        _storeLabel.text = _myPhoto.storeName;
    }else{
        _titleLabel.text = @"";
    }
}


- (void)addStoreButtonClicked:(id)sender {
    
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithSearchType:SearchTypeStores searchFilter:SearchFilterRandom];
    //searchRequest.coordinate = CLLocationCoordinate2DMake(42.283215, -71.123029);
    
    searchRequest.city = [SearchManager shared].city;
    searchRequest.state = [SearchManager shared].state;
    searchRequest.page = 1;//_page;
    //searchRequest.searchKey = _searchBar.text;
    //searchRequest.name = _searchBar.text;
    
    searchRequest.perPage = 100;
    
    //    if (_page == 1) {
    [self showSpinnerWithName:@""];
    //    }
    
    // self.searchOperation =
    [[MMServiceProvider sharedProvider] sendRequest:searchRequest success:^(SearchRequest* request) {
        NSLog(@"Succceess!");
        
        [self hideSpinnerWithName:@""];
        
        if ([request.objects isKindOfClass:[NSArray class]]) {
            [self.storeNamePickerView setPickerArray:request.objects];
            [self show:YES pickerAnimated:YES];
        }
        
        [self.storeNamePickerView setPickerArray:request.objects];
        [self show:YES pickerAnimated:YES];
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Can't load stores"];
       
    }];


}

- (void)show:(BOOL)value pickerAnimated:(BOOL)animated{

    if (value) {
        self.storePickerConstraint.constant = 216;
    }else{
        self.storePickerConstraint.constant = 0;
    }
    
    [UIView animateWithDuration:animated ? 0.3 : 0
                 animations:^{
                     [self.view layoutIfNeeded];
                 }
                 completion:^(BOOL finished) {
                     
                 }];
}

- (void) mapAction:(id)sender {
    
//    [self loadStoreInfoComletion:^{
//        [self showMapControllerForStore:_storeDetails];
//    }];
//    
//    return;
//    [[AlertManager shared] showOkAlertWithTitle:@"This functionality is not implemented yet"];
}

- (IBAction)storeButtonClicked:(UIButton *)sender {
//    StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
//    storeDetailsVC.storeDict = _storeDetails;
//    [self.navigationController pushViewController:storeDetailsVC animated:YES];

}


- (IBAction)callForPriceButton:(id)sender {
    [self callButtonClicked:nil];
}


//- (void)handleGesture:(UISwipeGestureRecognizer *)recognizer{
//    if([recognizer direction] == UISwipeGestureRecognizerDirectionLeft){
//        //Swipe from right to left
//        //Do your functions here
//        
//        if (self.index + 1 >= self.productsArray.count) {
//            [self.navigationController popToRootViewControllerAnimated:YES];
//            return;
//        }
//        
//        
//        ProductDetailsVC *vc = [ProductDetailsVC loadFromXIBForScrrenSizes];
//        vc.productsArray = self.productsArray;
//        vc.index = self.index + 1;;
//
//        [self.navigationController pushViewController:vc animated:YES];
//        
//        
//        NSLog(@"Swipe from right to left");
//    }else if([recognizer direction] == UISwipeGestureRecognizerDirectionRight){
//        //Swipe from left to right
//        //Do your functions here
//        
//        if (self.index <= 0) {
//            [self.navigationController popToRootViewControllerAnimated:YES];
//            return;
//        }
//        
//        ProductDetailsVC *vc = [ProductDetailsVC loadFromXIBForScrrenSizes];
//        vc.productsArray = self.productsArray;
//        vc.index = self.index - 1;
//        
//        NSMutableArray* navArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//        
//        [navArray insertObject:vc atIndex:navArray.count - 1];
//        self.navigationController.viewControllers = [NSArray arrayWithArray:navArray];
//        
//        [self.navigationController popViewControllerAnimated:YES];
//        
//        NSLog(@"Swipe from left to right");
//        
//    }
//}



#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
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

// Mail
- (void)sendMail {
    
    if ([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        
        [controller setSubject:@"A friend shared a \"local find\" on MainAndMe"];
        NSString* bodyString = @"";//[_product safeStringObjectForKey:@"name"];
        NSString* urlString = @"";//[NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[_product safeNumberObjectForKey:@"id"] stringValue]];
        bodyString = [NSString stringWithFormat:@"%@\n%@", bodyString, urlString];
        [controller setMessageBody:[NSString stringWithFormat:@"%@", bodyString] isHTML:NO];
        
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
            
            NSString* bodyString = @"Found this local gem on Main&Me:";
            //bodyString = [NSString stringWithFormat:@"%@\n%@", bodyString, [_product safeStringObjectForKey:@"name"]];
            NSString* urlString = @"";//[NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[_product safeNumberObjectForKey:@"id"] stringValue]];
             
            bodyString = [NSString stringWithFormat:@"You might like this gem I found in your neck of the woods:\n%@\n%@", bodyString, urlString];
            controller.body = bodyString;
            
            if (_imageView.image) {
                NSData *photoData = UIImageJPEGRepresentation(_imageView.image, 1);
                //[controller addAttachmentData:photoData typeIdentifier:(NSString *)kUTTypePNG filename:@"photo.png"];
                [controller addAttachmentData:photoData typeIdentifier:@"public.data" filename:@"image.png"];
            }
            
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
    //[self loginToTwitter];
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
    
    NSString* name = @"";//[_product safeStringObjectForKey:@"name"];
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
    
    NSString* imageUrl = @"";//[[_product safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
    NSString* description = @"";//[NSString stringWithFormat:@"%@\n %@",
                             //[_product safeStringObjectForKey:@"name"],
                             //[_product safeStringObjectForKey:@"description"]];
    
    NSString* urlString = @"";//[NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[_product safeNumberObjectForKey:@"id"] stringValue]];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"254708664663458", @"app_id",
                                   urlString, @"link",
                                   imageUrl, @"picture",
                                   //[_product safeStringObjectForKey:@"name"], @"name",
                                   @"Product", @"caption",
                                   description, @"description",
                                   @"I found this local gem on Main&Me",  @"message",
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
             [[AlertManager shared] showOkAlertWithTitle:@"Success" message:@"Posted to Facebook successfuly"];
         }
         
     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStoreInfoComletion:(void(^)())completion{
    
    
        LoadStoreRequest *storeRequest = [[LoadStoreRequest alloc] init];
        //storeRequest.storeId = [_product safeNSNumberObjectForKey:@"store_id"];
    
    
    [self showSpinnerWithName:@""];
        [[MMServiceProvider sharedProvider] sendRequest:storeRequest success:^(LoadStoreRequest *request) {
            [self hideSpinnerWithName:@""];
            NSLog(@"store: %@", request.storeDetails);
            
            self.storeDetails = request.storeDetails;
            
            [self updatePhoneButton];
            [self updateStoreLabel];
            
            completion();
            
        } failure:^(LoadStoreRequest *request, NSError *error) {
            [self hideSpinnerWithName:@""];
            NSLog(@"Error: %@", error);
            completion();
        }];

}

- (void)updatePhoneButton{
    
    self.phone = [_storeDetails safeObjectForKey:@"phone"];
    
//    if ([_phone isKindOfClass:[NSNull class]] || ![_phone isValidate]) {
//        self.phone = nil;
//        self.phoneButton.enabled = NO;
//    }else{
//        self.phoneButton.enabled = YES;
//    }
}

- (void)updateStoreLabel{
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    _storeLabel.attributedText = [[NSAttributedString alloc] initWithString:[_storeDetails safeStringObjectForKey:@"name"]
                                                             attributes:underlineAttribute];
    //_storeLabel.text = [_storeDetails safeStringObjectForKey:@"name"];
}

- (void)showMapControllerForStore:(NSDictionary*)storeDict{
    StoreMapViewController* vc = [StoreMapViewController loadFromXIBForScrrenSizes];
    vc.storeInfo = storeDict;
    [self.navigationController pushViewController:vc animated:YES];

}



/////


- (void)startSearch{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    //[self.searchOperation cancel];
    //_page = 1;
    [self searchRequest];
    
}


- (void)searchRequest{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithSearchType:SearchTypeStores searchFilter:SearchFilterRandom];
    //searchRequest.coordinate = CLLocationCoordinate2DMake(42.283215, -71.123029);
    
    searchRequest.city = [SearchManager shared].city;
    searchRequest.state = [SearchManager shared].state;
    searchRequest.page = 1;//_page;
    //searchRequest.searchKey = _searchBar.text;
    //searchRequest.name = _searchBar.text;
    
//    if (_page == 1) {
        [self showSpinnerWithName:@""];
//    }
    
   // self.searchOperation =
    [[MMServiceProvider sharedProvider] sendRequest:searchRequest success:^(SearchRequest* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
        
        //[_tableView.infiniteScrollingView stopAnimating];
        
//        if (_page == 1) {
//            self.tableArray = [NSMutableArray new];
//            [self.tableView reloadData];
//        }
        
//        if (request.objects.count > 0) {
//            [_tableArray addObjectsFromArray:request.objects];
//            _page ++;
//        }
        
        //[self sortData];
        //[_tableView reloadData];
        
        //self.searchOperation = nil;
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        
//        [_tableView.infiniteScrollingView stopAnimating];
//        _page = 1;
//        self.tableArray = [NSMutableArray new];
//        
//        [_tableView reloadData];
//        NSLog(@"error: %@", error);
        
//        self.searchOperation = nil;
    }];
}


//- (void)sortData{
//    
//    [_tableArray sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
//        NSString *first = [obj1 safeStringObjectForKey:@"name"];
//        NSString *second = [obj2 safeStringObjectForKey:@"name"];
//        
//        if (_sortType) {
//            return [second caseInsensitiveCompare:first];
//        }else{
//            return [first caseInsensitiveCompare:second];
//        }
//    }];
//}
//

@end
