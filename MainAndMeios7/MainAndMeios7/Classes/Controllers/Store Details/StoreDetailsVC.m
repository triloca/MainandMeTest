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


@interface StoreDetailsVC ()
<TMQuiltViewDataSource,
TMQuiltViewDelegate,
UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) TMQuiltView *quiltView;
@property (strong, nonatomic) NSMutableArray* collectionArray;

@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLable;
@property (strong, nonatomic) StoreDetailsView* storeDetailsView;

@property (strong, nonatomic) NSString *phone;
@property UIStatusBarStyle prevStyle;


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
    
    self.storeDict = [self.storesArray safeDictionaryObjectAtIndex:self.index];
    
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
    
    [self setupCollection];
    
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
    _quiltView.contentInset = UIEdgeInsetsMake(rc.size.height, 0, 0, 0);

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
        [wSelf callAction];
    };
    
    _storeDetailsView.didSelectFollowButton = ^(StoreDetailsView* view, UIButton* button){
        [wSelf followAction];
    };
    
    _storeDetailsView.didSelectShareButton = ^(StoreDetailsView* view, UIButton* button){
        [wSelf shareAction];
    };
    
    
    [_quiltView addSubview:_storeDetailsView];
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

- (void)configureCollectionFrame{
    
    CGRect rc = self.view.bounds;
    _quiltView.frame = rc;
    //_quiltView.backgroundColor  =[UIColor grayColor];
    
    
}

- (void)setupNavigationTitle{
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:[_storeDict safeStringObjectForKey:@"name"]
                                                         dropDownIndicator:NO
                                                             clickCallback:^(CustomTitleView *titleView) {}];

}

#pragma mark _______________________ Privat Methods ________________________


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
        [self.quiltView reloadData];
        
    } failure:^(LoadProductsByStoreRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        
        self.collectionArray = [NSMutableArray new];
        [_quiltView reloadData];
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
    }];
}

- (void)callAction {
    NSString *telLink = [NSString stringWithFormat:@"tel://%@", _phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telLink]];
}


- (void)followAction{

    FollowStoreRequest *request = [[FollowStoreRequest alloc] init];
    request.apiToken = [CommonManager shared].apiToken;
    request.storeId = [[_storeDict safeNumberObjectForKey:@"id"] stringValue];

    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
        [self hideSpinnerWithName:@""];
        NSLog(@"store was liked: %@", request.response);
        [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                            message:@"Store followed successfully"];
        //_storeDetailsCell.followImageView.hidden = NO;

    }failure:^(id _request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        
        if ([error.localizedDescription isEqualToString:@"You are already following this Store"]) {
            [[AlertManager shared] showOkAlertWithTitle:@"You are already following this store"];
        }else{
            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                message:error.localizedDescription];
        }
    }];


}


- (void)shareAction {
    
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
    [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark _______________________ Public Methods ________________________


#pragma mark _______________________ Notifications _________________________


@end
