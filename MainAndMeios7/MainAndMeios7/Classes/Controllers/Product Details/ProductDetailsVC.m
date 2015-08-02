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
#import "LoadStoreRequest.h"
#import "StoreMapViewController.h"
#import "WishlistPickerVC.h"
#import "ProductDetailsManager.h"
#import "StoreDetailsVC.h"
#import "NSString+Price.h"
#import "MMServiceProvider.h"
#import "SearchRequest.h"
#import "SearchManager.h"
#import "StoreNamePickerView.h"
#import "ShareView.h"
#import "AllStoresRequest.h"

@import Social;
#import "PinterestManager.h"
#import "UIImage+Scaling.h"

#import "ProductsStoresManager.h"

@interface ProductDetailsVC ()
<UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate>

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
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wishlistButtonWidthConstraint;

@property (weak, nonatomic) IBOutlet StoreNamePickerView *storeNamePickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storePickerConstraint;

@property (strong, nonatomic) NSDictionary* selectedStore;

@property (strong, nonatomic) ShareView* shareView;
@property (strong, nonatomic) NSLayoutConstraint* bottomConstraint;
@property (strong, nonatomic) UIDocumentInteractionController *docController;

@end

@implementation ProductDetailsVC

- (void)dealloc{

}

#pragma mark - Init

- (id) initWithProduct: (NSDictionary *) product {
    if (self = [super initWithNibName:@"ProductDetailsVC" bundle:nil]) {
        self.product = product;
    }
    return self;
}

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

    if (self.product == nil) {
        self.product = [self.productsArray safeDictionaryObjectAtIndex:self.index];
    }

    
    
    self.phone = nil;
    self.phoneButton.enabled = YES;
    __weak ProductDetailsVC* wSelf = self;
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"ITEM DETAIL" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        [[LayoutManager shared] showHomeControllerAnimated:YES];
        [wSelf.navigationController popToRootViewControllerAnimated:YES];

    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    [self updateRightNavigationButton];
    
    _titleLabel.text = [_product safeStringObjectForKey:@"name"];
    _descriptionLabel.text = [_product safeStringObjectForKey:@"description"];
    
    NSString* price = [_product safeStringObjectForKey:@"price"];
    if (price.length == 0 || [price isEqualToString:@"0.0"]) {
        //price = @"Call for price";
        _callForPriceButton.hidden = NO;
    }else{
        _callForPriceButton.hidden = YES;
    }
    _priceLabel.textColor = kAppColorGreen;
    
    _priceLabel.text = [price priceString];
    
    [self loadStoreInfoComletion:^{}];
    
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer];

    
    
    
    self.storeNamePickerView.onOkButton = ^(StoreNamePickerView* view, NSDictionary* store ,UIButton* button){
        

        
        [wSelf show:NO pickerAnimated:YES];
        
        
        [wSelf showSpinnerWithName:@""];
        [[ProductsStoresManager shared] addStoreName:[store safeStringObjectForKey:@"name"]
                                         toProductId:[[_product safeNumberObjectForKey:@"id"] stringValue]
                                             success:^(NSDictionary *prod) {
                                                 [wSelf hideSpinnerWithName:@""];
                                                 
                                                 if ([prod objectForKey:@"store_id"] && ![[prod objectForKey:@"store_id"] isKindOfClass:[NSNull class]]) {
                                                     _product = prod;
                                                     [wSelf loadStoreInfoComletion:^{
                                                         [wSelf hideSpinnerWithName:@""];
                                                         NSString* title = @"Success!";
                                                         NSString* messge = [NSString stringWithFormat:@"Added to store\n%@", [wSelf.storeDetails safeStringObjectForKey:@"name"]];
                                                         [[AlertManager shared] showOkAlertWithTitle:title message:messge];
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"kAddedStoreToProductNotification"
                                                                                                             object:nil];
                                                     }];
                                                 }else if ([[prod safeStringObjectForKey:@"message"] length] > 0){
                                                     [[AlertManager shared] showOkAlertWithTitle:[prod safeStringObjectForKey:@"message"]];
                                                 }
                                             }
                                             failure:^(NSError *error, NSString *errorString) {
                                                 [wSelf hideSpinnerWithName:@""];
                                             }
                                           exception:^(NSString *exceptionString) {
                                               [wSelf hideSpinnerWithName:@""];
                                           }];
    };
    
    self.storeNamePickerView.onCancelButton = ^(StoreNamePickerView* view, UIButton* button){
        [wSelf show:NO pickerAnimated:YES];
    };
    

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateWishlistButton];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSDictionary* imagesDict = [_product safeDictionaryObjectForKey:@"image"];
    NSString* mainImageURL = @"";
    mainImageURL = [imagesDict safeStringObjectForKey:@"full"];
    
    [self setupImageURL:mainImageURL];
    
    if (_needShowShareView) {
        _needShowShareView = NO;
        
        [self onSharingButton:nil];
    }
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
    if (_productsArray) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)callButtonClicked:(id)sender {
    
    if ([_phone isKindOfClass:[NSNull class]] || ![_phone isValidate]) {

        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"A number has not been provided for this store yet"
                                             message:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        
    }else{
        
        NSString* messageString = [NSString stringWithFormat:@"Call %@ at %@?", [_product safeStringObjectForKey:@"store_name"], _phone];
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView.cancelButtonIndex != buttonIndex) {
                [self callAction:nil];
            }
        }
                                               title:messageString
                                             message:nil
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Call", nil];

    }
}

- (IBAction)callAction:(id)sender {
    
    NSString* phone = [_phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *telLink = [NSString stringWithFormat:@"tel://%@", phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telLink]];
}

- (IBAction)shareAction:(id)sender {
    
    [self onSharingButton:nil];
    return;
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self
                                                         cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Email", @"SMS", nil];
    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    
    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}

- (IBAction)wishlistAction:(id)sender {
    
    WishlistPickerVC *picker = [WishlistPickerVC loadFromXIBForScrrenSizes];
    picker.hideMyPhotos = YES;
    picker.userId = [CommonManager shared].userId;
    picker.onSelectWishlistCallback = ^(NSDictionary *dict) {
        if (dict == nil) {
            [[AlertManager shared] showOkAlertWithTitle:@"MAIN AND ME" message:@"Unable to load wishlists. Please try again later"];
            return ;
        } else {
            __weak ProductDetailsVC *wself = self;
            [self showSpinnerWithName:@"Loading"];
            [ProductDetailsManager addToWishlist:dict[@"id"] productId:_product[@"id"] success:^() {
                
                NSString* message = [NSString stringWithFormat:@"This item has been added to your %@ wish list", [dict safeStringObjectForKey:@"name"]];
                
                [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }
                                                       title:@"Success"
                                                     message:message
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles:nil];
                
                [wself hideAllSpiners];
            } failure:^(NSError *error, NSString *errorString) {
                
                if ([errorString isEqualToString:@"This product is already added to this wishlist."]) {
                    errorString = @"You already added this item to this wish list";
                }
                [[AlertManager shared] showOkAlertWithTitle:errorString];
                
                
                [wself hideAllSpiners];
            } exception:^(NSString *exeptionString) {
                [[AlertManager shared] showOkAlertWithTitle:@"Error occured while adding item to wishlist. Please try again later"];
                [wself hideAllSpiners];
            }];
//            AddToWishlistRequest *request = [[AddToWishlistRequest alloc] init];
//            request.wishlistId = dict[@"id"];
//            request.productId = _product[@"id"];
//            
//            __weak ProductDetailsVC *wself = self;
//            [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//                [[AlertManager shared] showOkAlertWithTitle:@"Product was added to wishlist successfully"];
//                [wself hideAllSpiners];
//            } failure:^(id _request, NSError *error) {
//                [[AlertManager shared] showOkAlertWithTitle:@"Error occured while adding item to wishlist. Please try again later"];
//                [wself hideAllSpiners];
//            }];
        }
    };
    
    [self.navigationController pushViewController:picker animated:YES];
}

- (void) mapAction:(id)sender {
    
    [self loadStoreInfoComletion:^{
        [self showMapControllerForStore:_storeDetails];
    }];
    
    return;
    [[AlertManager shared] showOkAlertWithTitle:@"This functionality is not implemented yet"];
}

- (IBAction)storeButtonClicked:(UIButton *)sender {
    StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
    storeDetailsVC.storeDict = _storeDetails;
    [self.navigationController pushViewController:storeDetailsVC animated:YES];

}


- (IBAction)callForPriceButton:(id)sender {
    [self callButtonClicked:nil];
}


- (void)handleGesture:(UISwipeGestureRecognizer *)recognizer{
    if([recognizer direction] == UISwipeGestureRecognizerDirectionLeft){
        //Swipe from right to left
        //Do your functions here
        
        if (self.index + 1 >= self.productsArray.count) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
        
        
        ProductDetailsVC *vc = [ProductDetailsVC loadFromXIBForScrrenSizes];
        vc.productsArray = self.productsArray;
        vc.index = self.index + 1;;

        [self.navigationController pushViewController:vc animated:YES];
        
        
        NSLog(@"Swipe from right to left");
    }else if([recognizer direction] == UISwipeGestureRecognizerDirectionRight){
        //Swipe from left to right
        //Do your functions here
        
        if (self.index <= 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
        
        ProductDetailsVC *vc = [ProductDetailsVC loadFromXIBForScrrenSizes];
        vc.productsArray = self.productsArray;
        vc.index = self.index - 1;
        
        NSMutableArray* navArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        
        [navArray insertObject:vc atIndex:navArray.count - 1];
        self.navigationController.viewControllers = [NSArray arrayWithArray:navArray];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        NSLog(@"Swipe from left to right");
        
    }
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
        NSString* bodyString = [_product safeStringObjectForKey:@"name"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[_product safeNumberObjectForKey:@"id"] stringValue]];
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
        
        __weak ProductDetailsVC* wSelf = self;
        
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
            
            NSDictionary* obj = _product;
            
            NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
            
            
            [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
            [bodyString appendString:@"\n"];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
            [bodyString appendString:urlString];
            //[bodyString appendString:@".\n"];
            
            
            NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
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
        
        NSDictionary* obj = _product;
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        
            
            [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
            [bodyString appendString:@"\n"];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
            [bodyString appendString:urlString];
            //[bodyString appendString:@".\n"];
            
            
            NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
            NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            if (photoData) {
                [controller addAttachmentData:photoData mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"photo.png"]];
            }
       
        
        
        [controller setSubject:@"A friend shared a \"local find\" on MainAndMe"];
        [controller setMessageBody:[NSString stringWithFormat:@"%@", bodyString] isHTML:NO];
        
        [self presentViewController:controller animated:YES completion:^{}];
        
    } else {
        [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via Email"];
    }
    
    
    [self hideSpinnerWithName:@""];
}

- (void)shareTwitter{
    
    // No Twitter Account
    // There are no Twitter acconts configured. You can add or create a Twitter account in Settings
    // Cancel Settings
    
    // Confirm that a Twitter account exists
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        
        
        // Create a compose view controller for the service type Twitter
        SLComposeViewController *twController = ({
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
        
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        NSDictionary* obj = _product;
        //for (NSDictionary* obj in self.sharingObjectsArray) {
        
        [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
        [bodyString appendString:@"\n"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
        [bodyString appendString:urlString];
        //[bodyString appendString:@".\n\n"];
        
        
        NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage* image = [UIImage imageWithData:photoData];
        
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
    
    [self hideSpinnerWithName:@""];
    
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
        
        
        NSDictionary* obj = _product;
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        
            [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
            [bodyString appendString:@"\n"];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
            [bodyString appendString:urlString];
            [bodyString appendString:@".\n\n"];
            
            
            NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
            NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            UIImage* image = [UIImage imageWithData:photoData];
            
            if (image) {
                [fbController addImage:image];
            }
        
        
        
        [fbController setInitialText:bodyString];
        [fbController addURL:[NSURL URLWithString:@"http://www.mainandme.com"]];
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
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
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];

        NSDictionary* obj = _product;
        //for (NSDictionary* obj in self.sharingObjectsArray) {
        
        [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
        [bodyString appendString:@"\n"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
        [bodyString appendString:urlString];
        [bodyString appendString:@".\n\n"];
        
        
        NSString* imageURLStr = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"];
        
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
    
    
    NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];

    NSDictionary* obj = _product;
    //for (NSDictionary* obj in self.sharingObjectsArray) {
    
    [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
    [bodyString appendString:@"\n"];
    //NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
    //[bodyString appendString:urlString];
    //[bodyString appendString:@""];
    
    
    NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
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


#pragma mark - Privat Methods

- (void)addSotoreName:(NSString*)name{
    LoadStoreRequest *storeRequest = [[LoadStoreRequest alloc] init];
    storeRequest.storeId = [_product safeNSNumberObjectForKey:@"store_id"];
    
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:storeRequest success:^(LoadStoreRequest *request) {
        [self hideSpinnerWithName:@""];
        NSLog(@"store: %@", request.storeDetails);
        
        self.storeDetails = request.storeDetails;
        
        [self updatePhoneButton];
        [self updateStoreLabel];
        
        //completion();
        
    } failure:^(LoadStoreRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        //completion();
    }];

}


- (void)updateRightNavigationButton{

    if ([[_product objectForKey:@"store_id"] isKindOfClass:[NSNull class]]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add store?"
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(addStoreButtonClicked:)];
    }else{
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_map_button"]
                                                                    landscapeImagePhone:nil
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(mapAction:)];
    }

}


- (void)addStoreButtonClicked:(id)sender {
    
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    //[self searchRequest];
    
    //return;
    
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

- (void)searchRequest{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    AllStoresRequest* allStoresRequest = [[AllStoresRequest alloc] initWithCommunity:[SearchManager shared].communityID];
    allStoresRequest.page = 1;
    allStoresRequest.perPage = 100;

    [self showSpinnerWithName:@""];

    [[MMServiceProvider sharedProvider] sendRequest:allStoresRequest success:^(SearchRequest* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
        
        [self.storeNamePickerView setPickerArray:request.objects];
        [self show:YES pickerAnimated:YES];
        
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [[AlertManager shared] showOkAlertWithTitle:error.localizedDescription];
        [self hideSpinnerWithName:@""];
        
    }];
}


- (void)show:(BOOL)value pickerAnimated:(BOOL)animated{
    
    [self.view bringSubviewToFront:self.storeNamePickerView];
    
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


- (void)sendSms{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            
            NSString* bodyString = @"Found this local gem on Main&Me:";
            bodyString = [NSString stringWithFormat:@"%@\n%@", bodyString, [_product safeStringObjectForKey:@"name"]];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[_product safeNumberObjectForKey:@"id"] stringValue]];
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

#pragma mark -  FB
- (IBAction)shareButtonClicked:(id)sender
{
    
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
             
             NSString* imageUrl = [[_product safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
             NSString* description = [NSString stringWithFormat:@"%@\n %@",
                                      [_product safeStringObjectForKey:@"name"],
                                      [_product safeStringObjectForKey:@"description"]];
             
             NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[_product safeNumberObjectForKey:@"id"] stringValue]];
             
             
             //NSString *str_img = [NSString stringWithFormat:@"https://raw.github.com/fbsamples/ios-3.x-howtos/master/Images/iossdk_logo.png"];
             
             NSDictionary *params = @{
                                      @"name" :@"I found this local gem on Main&Me",
                                      @"caption" : [_product safeStringObjectForKey:@"store_name"],
                                      @"description" :description,
                                      @"picture" : imageUrl,
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
    
    NSString* imageUrl = [[_product safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
    NSString* description = [NSString stringWithFormat:@"%@\n %@",
                             [_product safeStringObjectForKey:@"name"],
                             [_product safeStringObjectForKey:@"description"]];
    
    NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[_product safeNumberObjectForKey:@"id"] stringValue]];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"254708664663458", @"app_id",
                                   urlString, @"link",
                                   imageUrl, @"picture",
                                   [_product safeStringObjectForKey:@"name"], @"name",
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
        storeRequest.storeId = [_product safeNSNumberObjectForKey:@"store_id"];
    
    
    [self showSpinnerWithName:@""];
        [[MMServiceProvider sharedProvider] sendRequest:storeRequest success:^(LoadStoreRequest *request) {
            [self hideSpinnerWithName:@""];
            NSLog(@"store: %@", request.storeDetails);
            
            self.storeDetails = request.storeDetails;
            
            [self updatePhoneButton];
            [self updateStoreLabel];
            [self updateRightNavigationButton];
            
            completion();
            
        } failure:^(LoadStoreRequest *request, NSError *error) {
            [self hideSpinnerWithName:@""];
            NSLog(@"Error: %@", error);
            [self updateRightNavigationButton];
            completion();
        }];

}

- (void)updatePhoneButton{
    
    self.phone = [_storeDetails safeObjectForKey:@"phone"];
    
    if ([_phone isKindOfClass:[NSNull class]] || ![_phone isValidate]) {
        self.phone = nil;
        self.phoneButton.enabled = NO;
    }else{
        self.phoneButton.enabled = YES;
    }
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


- (void)updateWishlistButton{
    if ([[_product safeStringObjectForKey:@"state"] isEqualToString:@"active"] || 1) {
        self.wishlistButton.hidden = NO;
        self.wishlistButtonWidthConstraint.constant = 80;
    }else{
        self.wishlistButton.hidden = YES;
        self.wishlistButtonWidthConstraint.constant = 0;
    }
}

@end
