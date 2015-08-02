//
//  StoreDetailsVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "StoreDetailsVC.h"
#import "UIFont+All.h"
#import "TMQuiltView.h"
#import "HomeItemCell.h"
#import "LoadProductsRequest.h"
#import "CustomTitleView.h"
#import "LoadProductsByStoreRequest.h"
#import "ProductDetailsVC.h"
#import "HomeStoreCell.h"
#import "StoreDetailsView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"
#import "FollowStoreRequest.h"

#import "StoreMapViewController.h"
#import "ProductCell.h"

#import "StoreNamePickerView.h"
#import "ShareView.h"

@import Social;
#import "PinterestManager.h"
#import "UIImage+Scaling.h"

#import "LoadStoreRequest.h"

static NSString *kProductCellIdentifier = @"ProductCell";


@interface StoreDetailsVC ()
<TMQuiltViewDataSource,
TMQuiltViewDelegate,
UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) TMQuiltView *quiltView;
@property (strong, nonatomic) NSMutableArray* collectionArray;

@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLable;
@property (strong, nonatomic) StoreDetailsView* storeDetailsView;

@property (strong, nonatomic) NSString *phone;
@property UIStatusBarStyle prevStyle;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ShareView* shareView;
@property (strong, nonatomic) NSLayoutConstraint* bottomConstraint;

@property (strong, nonatomic) UIDocumentInteractionController *docController;

@end

@implementation StoreDetailsVC

#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc{

}
#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.storeDict == nil) {
        self.storeDict = [self.storesArray safeDictionaryObjectAtIndex:self.index];
    }
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"nav_back_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_map_button"]
                                                                landscapeImagePhone:nil
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(mapAction:)];
    [self setupNavigationTitle];
    _titleTextLable.text = [_storeDict safeStringObjectForKey:@"name"];

    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer];
    
    //[self setupCollection];
    
    [self setupStoreDetailsView];
    
    [self.view bringSubviewToFront:_backButton];
    [self.view bringSubviewToFront:_titleTextLable];
    [self.view bringSubviewToFront:_mapButton];

    self.collectionArray = [NSMutableArray new];
    
    [self loadProducts];
    
    [self updatePhoneButton];
    
 }


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.prevStyle = [UIApplication sharedApplication].statusBarStyle;
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
    //[self.navigationController setNavigationBarHidden:YES];

    [_storeDetailsView layoutIfNeeded];
    [_quiltView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    
    //[self.navigationController setNavigationBarHidden:NO];

}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self configureCollectionFrame];
    CGRect rc = _storeDetailsView.bounds;
    rc.origin.y -= rc.size.height;
    _storeDetailsView.frame = rc;
    //_quiltView.contentInset = UIEdgeInsetsMake(rc.size.height, 0, 0, 0);
    _tableView.contentInset = UIEdgeInsetsMake(rc.size.height, 0, 0, 0);

}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark _______________________ Privat Methods(view)___________________

- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (void)setupCollection{
    
    self.quiltView = [[TMQuiltView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _quiltView.delegate = self;
    _quiltView.dataSource = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_quiltView];
    _quiltView.backgroundColor = [UIColor clearColor];
    
    

}


- (void)setupStoreDetailsView{
    
    __weak StoreDetailsVC* wSelf = self;
    
    self.storeDetailsView = [StoreDetailsView loadViewFromXIB];
    
    
    _storeDetailsView.didSelectCallButton = ^(StoreDetailsView* view, UIButton* button){
        [wSelf callAction:wSelf.storeDict];
    };
    
    _storeDetailsView.didSelectFollowButton = ^(StoreDetailsView* view, UIButton* button){
        if ([[wSelf.storeDict safeNumberObjectForKey:@"is_following"] boolValue]) {
            [wSelf followActionUnfollow:YES];
        }else{
            [wSelf followActionUnfollow:NO];
        }
        
        
    };
    
    _storeDetailsView.didSelectShareButton = ^(StoreDetailsView* view, UIButton* button){
        [wSelf shareAction];
    };
    
    
    //[_quiltView addSubview:_storeDetailsView];
    
    [_tableView addSubview:_storeDetailsView];
    
    [self.view setNeedsLayout];
    
//    NSLayoutConstraint *width =[NSLayoutConstraint
//                                constraintWithItem:_storeDetailsView
//                                attribute:NSLayoutAttributeWidth
//                                relatedBy:NSLayoutRelationEqual
//                                toItem:contentView
//                                attribute:NSLayoutAttributeWidth
//                                multiplier:1.0
//                                constant:1];
//    
//    [_storeDetailsView addConstraint:width];
//
    
    [_storeDetailsView setStoreDict:_storeDict];
}

- (void)updataStoreDetailsView{

    [_storeDetailsView setStoreDict:_storeDict];

}

- (void)configureCollectionFrame{
    
    CGRect rc = self.view.bounds;
    _quiltView.frame = rc;
    //_quiltView.backgroundColor  =[UIColor grayColor];
    
    
}

- (void)setupNavigationTitle{
    __weak StoreDetailsVC* wSelf = self;
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:[_storeDict safeStringObjectForKey:@"name"]
                                                         dropDownIndicator:NO
                                                             clickCallback:^(CustomTitleView *titleView) {
                                                             
                                                                 [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
                                                                 [[LayoutManager shared] showHomeControllerAnimated:YES];
                                                                 [wSelf.navigationController popToRootViewControllerAnimated:YES];

                                                             }];

}


- (void)onClickWithItemDict:(NSDictionary*)itemDict{
    
    if ([itemDict.allKeys containsObject:@"price"]) {
        ProductDetailsVC *vc = [[ProductDetailsVC alloc] initWithProduct:itemDict];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
        storeDetailsVC.storeDict = itemDict;
        [self.navigationController pushViewController:storeDetailsVC animated:YES];
    }
}

#pragma mark _______________________ Privat Methods ________________________


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
        
        __weak StoreDetailsVC* wSelf = self;
        
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
            
            NSDictionary* obj = _storeDict;
            
            NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
            
            
            [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
            [bodyString appendString:@"\n"];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
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
        
        NSDictionary* obj = _storeDict;
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        
        
        [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
        [bodyString appendString:@"\n"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
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
        NSDictionary* obj = _storeDict;
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
    
    [self fBbuttonClicked];
    
    return;
    
    
    SLComposeViewController *fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];

    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        
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
        
        
        NSDictionary* obj = _storeDict;
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        
        [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
        [bodyString appendString:@"\n"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
        [bodyString appendString:urlString];
        //[bodyString appendString:@"."];
        
        
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
        
        NSDictionary* obj = _storeDict;
        //for (NSDictionary* obj in self.sharingObjectsArray) {
        
        [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
        [bodyString appendString:@"\n"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
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
    
    NSDictionary* obj = _storeDict;
    //for (NSDictionary* obj in self.sharingObjectsArray) {
    
    [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
    [bodyString appendString:@"\n"];
    //NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
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
        _docController.delegate = self;
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
#pragma mark -
- (void)loadStoreInfoComletion:(void(^)(NSDictionary* storeDict))completion{
    
    
    LoadStoreRequest *storeRequest = [[LoadStoreRequest alloc] init];
    storeRequest.storeId = [_storeDict safeNSNumberObjectForKey:@"id"];
    
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:storeRequest success:^(LoadStoreRequest *request) {
        [self hideSpinnerWithName:@""];
        NSLog(@"store: %@", request.storeDetails);
        
        self.storeDict = request.storeDetails;
        
//        [self updatePhoneButton];
//        [self updateStoreLabel];
//        [self updateRightNavigationButton];
        
        completion(self.storeDict);
        
    } failure:^(LoadStoreRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        //[self updateRightNavigationButton];
        completion(nil);
    }];
    
}

- (void)loadProducts{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    
    LoadProductsByStoreRequest *productsRequest = [[LoadProductsByStoreRequest alloc] init];
    productsRequest.storeId = [_storeDict safeNumberObjectForKey:@"id"];
    productsRequest.latest = YES;
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:productsRequest success:^(LoadProductsByStoreRequest *request) {
        [self hideSpinnerWithName:@""];
        NSLog(@"products: %@", request.products);
        
        self.collectionArray = [NSMutableArray arrayWithArray:request.products];
        //[self.quiltView reloadData];
        [self.tableView reloadData];
        
    } failure:^(LoadProductsByStoreRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        
        self.collectionArray = [NSMutableArray new];
        //[_quiltView reloadData];
        [self.tableView reloadData];
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
    }];
}

- (void)callAction {
    NSString *telLink = [NSString stringWithFormat:@"tel://%@", _phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telLink]];
}


- (void)callAction:(NSDictionary*)store {
    
    NSString* phone = _phone;//[store safeStringObjectForKey:@"phone"];
    if ([phone isKindOfClass:[NSNull class]] || ![phone isValidate]) {
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"A number has not been provided for this store yet"
                                             message:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        
    }else{
        
//        NSString* messageString = [NSString stringWithFormat:@"Call %@ at %@?", [[store safeDictionaryObjectForKey:@"user"] safeStringObjectForKey:@"name"], phone];
        
        NSString* messageString = [NSString stringWithFormat:@"Call %@ at %@?", [store safeStringObjectForKey:@"name"], phone];
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView.cancelButtonIndex != buttonIndex) {
                [self callToAction:phone];
            }
        }
                                               title:messageString
                                             message:nil
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Call", nil];
        
    }
}

- (void)callToAction:(NSString*)phone {
    
    phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *telLink = [NSString stringWithFormat:@"tel://%@", phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telLink]];
}


- (void)followActionUnfollow:(BOOL)unfollow{

    FollowStoreRequest *request = [[FollowStoreRequest alloc] init];
    request.apiToken = [CommonManager shared].apiToken;
    request.storeId = [[_storeDict safeNumberObjectForKey:@"id"] stringValue];

    request.unfollow = unfollow;
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
        
        NSLog(@"store was liked: %@", request.response);
        
        //_storeDetailsCell.followImageView.hidden = NO;
        
        [self loadStoreInfoComletion:^(NSDictionary* storeDict){
            [self updataStoreDetailsView];
            [self hideSpinnerWithName:@""];
            
            NSString* message = @"";
            if (unfollow) {
                message = @"Store unfollowed successfully";
            }else{
                message = @"Store followed successfully";
            }
            
            [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                                message:message];
            
            [[LayoutManager shared].homeVC updateStore:storeDict];
            
        }];

    }failure:^(id _request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        
        if ([error.localizedDescription isEqualToString:@"You are already following this Store"]) {
            [[AlertManager shared] showOkAlertWithTitle:@"You are already following this store"];
        }else{
            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                message:error.localizedDescription];
        }
        
        [self loadStoreInfoComletion:^(NSDictionary* storeDict){
            [self updataStoreDetailsView];
            [self hideSpinnerWithName:@""];
            
        }];

    }];


}


- (void)shareAction {
    
    [self onSharingButton:nil];
    return;
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self
                                                         cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Email", @"SMS", nil];
    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    
    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}


- (void)updatePhoneButton{

    self.phone = [_storeDict safeObjectForKey:@"phone"];
    if (![_phone isValidate])
        self.phone = [_storeDict safeObjectForKey:@"phone_number"];
    if ([_phone isKindOfClass:[NSNull class]] || ![_phone isValidate]) {
        self.phone = nil;
        self.storeDetailsView.callButton.hidden = YES;
    }
}
- (void)sendSms{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            
            
            NSString* bodyString = @"Found this local gem on Main&Me:";
            bodyString = [NSString stringWithFormat:@"%@\n%@", bodyString, [_storeDict safeStringObjectForKey:@"name"]];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[_storeDict safeNumberObjectForKey:@"id"] stringValue]];
            bodyString = [NSString stringWithFormat:@"%@\n%@", bodyString, urlString];
            controller.body = bodyString;
            
            if (_storeDetailsView.storeImageView.image) {
                NSData *photoData = UIImageJPEGRepresentation(_storeDetailsView.storeImageView.image, 1);
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
    
    NSString* name = [_storeDict safeStringObjectForKey:@"name"];
    name = [name stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
    NSString* text = [NSString stringWithFormat:@"Main And Me app\n%@", name];
    
    UIImage* image = _storeDetailsView.storeImageView.image;
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
             
             NSString* imageUrl = [[_storeDict safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
             NSString* description = [NSString stringWithFormat:@"%@",
                                      //[_storeDict safeStringObjectForKey:@"name"],
                                      [_storeDict safeStringObjectForKey:@"description"]];
             
             NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[_storeDict safeNumberObjectForKey:@"id"] stringValue]];

             
             //NSString *str_img = [NSString stringWithFormat:@"https://raw.github.com/fbsamples/ios-3.x-howtos/master/Images/iossdk_logo.png"];
             
             NSDictionary *params = @{
                                      @"name" :@"I found this local gem on Main&Me",
                                      @"caption" : [_storeDict safeStringObjectForKey:@"name"],
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
    
    return;
}


- (void)fBbuttonClicked{
    
    [self shareButtonClicked:nil];
    return;
    [self openFBSession];
}

- (void)openFBSession {
    
    if (FBSession.activeSession.isOpen) {
        if ([FBSession.activeSession.permissions containsObject:@"publish_stream"]) {
            [self loadMeFacebook];
        }else{
            [FBSession.activeSession requestNewPublishPermissions:@[@"publish_stream"]
                                                  defaultAudience:FBSessionDefaultAudienceEveryone
                                                completionHandler:^(FBSession *session, NSError *error) {
                                                    [self loadMeFacebook];
                                                }];
        }
        
    } else {
        
        if (![ReachabilityManager isReachable]) {
            [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
            return;
        }
        
        NSArray* permissions = [[NSArray alloc] initWithObjects:@"publish_actions", nil];
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
    
    NSString* imageUrl = [[_storeDict safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
    NSString* description = [NSString stringWithFormat:@"%@\n %@",
                             [_storeDict safeStringObjectForKey:@"name"],
                             [_storeDict safeStringObjectForKey:@"description"]];
    
    NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[_storeDict safeNumberObjectForKey:@"id"] stringValue]];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"254708664663458", @"app_id",
                                   urlString, @"link",
                                   imageUrl, @"picture",
                                   [_storeDict safeStringObjectForKey:@"name"], @"name",
                                   @"Store", @"caption",
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

// Mail
- (void)sendMail {
    
    if ([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"A friend shared a \"local find\" on MainAndMe"];

        NSString* bodyString = [_storeDict safeStringObjectForKey:@"name"];
        
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[_storeDict safeNumberObjectForKey:@"id"] stringValue]];
        bodyString = [NSString stringWithFormat:@"You might like this gem I found in your neck of the woods:\n%@\n%@", bodyString, urlString];
        [controller setMessageBody:[NSString stringWithFormat:@"%@", bodyString] isHTML:NO];
        
        if (_storeDetailsView.storeImageView.image) {
            NSData *photoData = UIImageJPEGRepresentation(_storeDetailsView.storeImageView.image, 1);
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


- (void)handleGesture:(UISwipeGestureRecognizer *)recognizer{
    if([recognizer direction] == UISwipeGestureRecognizerDirectionLeft){
        //Swipe from right to left
        //Do your functions here
        
        if (self.index + 1 >= self.storesArray.count) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
        
        StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
        storeDetailsVC.storesArray = self.storesArray;
        storeDetailsVC.index = self.index + 1;
        
//        StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
//        storeDetailsVC.storeDict = self.storeDict;
        [self.navigationController pushViewController:storeDetailsVC animated:YES];

        
        NSLog(@"Swipe from right to left");
    }else if([recognizer direction] == UISwipeGestureRecognizerDirectionRight){
        //Swipe from left to right
        //Do your functions here
        
        if (self.index <= 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
        
        StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
        storeDetailsVC.storesArray = self.storesArray;
        storeDetailsVC.index = self.index - 1;
        
        NSMutableArray* navArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        
        [navArray insertObject:storeDetailsVC atIndex:navArray.count - 1];
        self.navigationController.viewControllers = [NSArray arrayWithArray:navArray];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        NSLog(@"Swipe from left to right");
        
    }
}

#pragma mark _______________________ Buttons Action ________________________

- (void)backButtonClicked{
    [UIImageView clearMemoryImageCache];
    
    if (_storesArray) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) mapAction: (id) sender {
    
    StoreMapViewController* vc = [StoreMapViewController loadFromXIBForScrrenSizes];
    vc.storeInfo = _storeDict;
    [self.navigationController pushViewController:vc animated:YES];
    
    return;
    [[AlertManager shared] showOkAlertWithTitle:@"This functionality is not implemented yet"];
}

- (IBAction)customBackButtinClicked:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)customMapButtonClicked:(id)sender {
    
    [self mapAction:nil];
    
    return;
    
    [[AlertManager shared] showOkAlertWithTitle:@"This functionality is not implemented yet"];
}

#pragma mark _______________________ Delegates _____________________________


#pragma mark - QuiltViewControllerDataSource


- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return _collectionArray.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    
    
    HomeItemCell *cell = (HomeItemCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeItemCell"];
    if (!cell) {
        cell = [HomeItemCell loadViewFromXIB];
        [cell setReuseIdentifier:@"HomeItemCell"];
    }
    
    
    NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    cell.storeDict = storeDict;
    
    return cell;
    
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

#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
   
    NSDictionary *dict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    ProductDetailsVC *vc = [[ProductDetailsVC alloc] initWithProduct:dict];
    [self.navigationController pushViewController:vc animated:YES];

}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 2;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
   CGFloat height = [HomeStoreCell cellHeghtForStore:storeDict];
    
    return height;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return tableView.frame.size.width / 3 + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [_collectionArray count];
    NSInteger temp = count % 3;
    NSInteger rowsCount = count / 3;
    if (temp > 0) {
        rowsCount++;
    }
    
    
    return rowsCount;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProductCell* cell = [self productCellForIndexPath:indexPath];
    return cell;
}

- (ProductCell*)productCellForIndexPath:(NSIndexPath*)indexPath{
    ProductCell *cell = [_tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier];
    
    //    if (_isEditing) {
    //        [cell.firstView startVibration];
    //        [cell.secondView startVibration];
    //        [cell.thirdView startVibration];
    //    }else{
    //        [cell.firstView stopVibration];
    //        [cell.secondView stopVibration];
    //        [cell.thirdView stopVibration];
    //    }
    
    
    if (cell == nil){
        cell = [ProductCell loadViewFromXIB];
        
        cell.didClickAtIndex = ^(NSInteger selectedIndex){
            NSDictionary* dict = [_collectionArray safeObjectAtIndex:selectedIndex];
            //
            [self onClickWithItemDict:dict];
            
            //if (_isEditing) {
            //                //! Delete alert
            //                [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            //                    if (alertView.cancelButtonIndex == buttonIndex) {
            //
            //                    }else{
            //                        [_items removeObject:dict];
            //                        [_tableView reloadData];
            //                        [self updateEditButton];
            //                        [ProductDetailsManager deleteProduct:dict[@"id"] inWishlist:_wishlist[@"id"] success:nil failure:nil exception:nil];
            //
            //                    }
            //                }
            //                                                       title:@"Delete this photo?"
            //                                                     message:@""
            //                                           cancelButtonTitle:@"Cancel"
            //                                           otherButtonTitles:@"Delete", nil];
            //
            //
            //            }else{
            //                ProductDetailsVC *vc = [ProductDetailsVC loadFromXIB_Or_iPhone5_XIB];
            //                vc.product = dict;
            //                [self.navigationController pushViewController:vc animated:YES];
            //            }
        };
    }
    
    // Configure the cell...
    
    NSInteger index = indexPath.row * 3;
    
    if ([_collectionArray count] > index) {
        NSDictionary* object = [_collectionArray safeDictionaryObjectAtIndex:index];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
        [cell.firstView setImageURLString:imageUrl];
        cell.firstView.hidden = NO;
        
    }else{
        cell.firstView.hidden = YES;
    }
    cell.firstView.coverButton.tag = index;
    
    if ([_collectionArray count] > index + 1) {
        NSDictionary* object = [_collectionArray safeDictionaryObjectAtIndex:index + 1];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
        [cell.secondView setImageURLString:imageUrl];
        cell.secondView.hidden = NO;
    }else{
        cell.secondView.hidden = YES;
    }
    cell.secondView.coverButton.tag = index + 1;
    
    if ([_collectionArray count] > index + 2) {
        NSDictionary* object = [_collectionArray safeDictionaryObjectAtIndex:index + 2];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
        [cell.thirdView setImageURLString:imageUrl];
        cell.thirdView.hidden = NO;
    }else{
        cell.thirdView.hidden = YES;
    }
    cell.thirdView.coverButton.tag = index + 2;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark _______________________ Public Methods ________________________


#pragma mark _______________________ Notifications _________________________


@end
