//
//  ProductDetailViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "ProductDetailViewController.h"
#import "ProductDetailsCell.h"
#import "UIView+Common.h"
#import "CommentCell.h"
#import "ProductDetailsManager.h"
#import "MBProgressHUD.h"
#import "AlertManager.h"
#import "DataManager.h"
#import "ReachabilityManager.h"
#import "AddCommentViewController.h"
#import "LayoutManager.h"
#import "WishlistViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "UserDefaultsManager.h"
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"
#import "StoreDetailsManager.h"
#import "StoreDetailViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "DescriptionCell.h"
#import "NotificationManager.h"

@interface ProductDetailViewController ()
<UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;

@property (strong, nonatomic) ProductDetailsCell* productDetailsCell;

@end

@implementation ProductDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Product Details screen";
    
    // Do any additional setup after loading the view from its nib.
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Product details";
    
    _productDetailsCell = [ProductDetailsCell loadViewFromXIB];
    
    NSString* imageUrl = [[_productInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"];
    [_productDetailsCell setProductImageURLString:imageUrl];
    
    [_productDetailsCell setName:[_productInfo safeStringObjectForKey:@"store_name"]];
    
    
    __weak ProductDetailViewController* weak_self = self;
    _productDetailsCell.didClickStoreName = ^(ProductDetailsCell* cell){
        [weak_self loadStoreById:[[weak_self.productInfo safeNumberObjectForKey:@"store_id"] stringValue]];
    };
  
    NSDate* date = [DataManager dateFromString:[_productInfo safeStringObjectForKey:@"created_at"]];
    _productDetailsCell.agoLabel.text = [DataManager howLongAgo:date];
    
    [_productDetailsCell.likeButton addTarget:self
                                       action:@selector(likeButtonClicked:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [_productDetailsCell.commentButton addTarget:self
                                          action:@selector(commentButtonClicked:)
                                forControlEvents:UIControlEventTouchUpInside];
    
    [_productDetailsCell.addToWishlistButton addTarget:self
                                                action:@selector(addToWishlistButtonClicked:)
                                      forControlEvents:UIControlEventTouchUpInside];
    [_productDetailsCell.shareButton addTarget:self
                                        action:@selector(shareButtonClicked:)
                              forControlEvents:UIControlEventTouchUpInside];

   
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self loadProfileInfo];
    [self removeNotification];
       
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    [self loadComments];
}

- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (void)fBbuttonClicked{
    [self openFBSession];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)likeButtonClicked:(UIButton*)sender{
    [self likeProduct];
}

- (void)commentButtonClicked:(UIButton*)sender{
    AddCommentViewController* addCommentViewController = [AddCommentViewController loadFromXIB_Or_iPhone5_XIB];
    addCommentViewController.productInfo = _productInfo;
    addCommentViewController.isStoreState = NO;
    [self.navigationController pushViewController:addCommentViewController animated:YES];
}


- (void)addToWishlistButtonClicked:(UIButton*)sender{
     [self showWishlist];
}


- (void)shareButtonClicked:(id)sender {
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self
                                                         cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Email", @"SMS", nil];
    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    UIButton *button = [[shareActionSheet subviews] safeObjectAtIndex:1];
    [button setTitleColor:[UIColor colorWithRed:99/255.0f green:116/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:127/255.0f green:166/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateHighlighted];
    
    button = [[shareActionSheet subviews] safeObjectAtIndex:2];
    [button setTitleColor:[UIColor colorWithRed:99/255.0f green:116/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:127/255.0f green:166/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateHighlighted];
    
    button = [[shareActionSheet subviews] safeObjectAtIndex:3];
    [button setTitleColor:[UIColor colorWithRed:99/255.0f green:116/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:127/255.0f green:166/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateHighlighted];
    
    button = [[shareActionSheet subviews] safeObjectAtIndex:4];
    [button setTitleColor:[UIColor colorWithRed:99/255.0f green:116/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:127/255.0f green:166/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateHighlighted];
    
    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    UIColor* backColor = [UIColor colorWithRed:205/255.0f green:133/255.0f blue:63/255.0f alpha:0.7];
    [[actionSheet layer] setBackgroundColor:backColor.CGColor];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 368;
            break;
        case 1:{
            return [DescriptionCell cellHeight:[_productInfo safeStringObjectForKey:@"description"]];
            break;
        }
        case 2:{
            NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
            return [CommentCell cellHeight:[object safeStringObjectForKey:@"body"]];
            break;
        }
            
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        if ([[_productInfo safeStringObjectForKey:@"description"] length] > 0) {
            return 1;
        }else{
            return 0;
        }
    }
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCommentCellIdentifier = @"CommentCell";
    static NSString *kDescriptionCellIdentifier = @"DescriptionCell";

    
    if (indexPath.section == 0) {
       
        return _productDetailsCell;

    }else if (indexPath.section == 1){
    
        DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:kDescriptionCellIdentifier];
        
        if (cell == nil){
            cell = [DescriptionCell loadViewFromXIB];
        }
        
        // Configure the cell...
        
        [cell setMessageText:[_productInfo safeStringObjectForKey:@"description"]];
        return cell;

    }else if (indexPath.section == 2){
        
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
        
        if (cell == nil){
            cell = [CommentCell loadViewFromXIB];
        }
        
        // Configure the cell...
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
        
        [cell setMessageText:[object safeStringObjectForKey:@"body"]];
        [cell setCellData:object];
        return cell;
        
    }
    return [[UITableViewCell alloc] init];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    [self dismissModalViewControllerAnimated:YES];
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
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Privat Methods

- (void)sendSms{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            controller.body = [NSString stringWithFormat:@"%@", [_productInfo safeStringObjectForKey:@"name"]];
            controller.messageComposeDelegate = self;
            [self presentModalViewController:controller animated:YES];
        } else {
            [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via SMS"];
        }
    }
}

- (void)sendMail {
    
    if ([MFMailComposeViewController canSendMail]){

        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Recommendation for MainAndMe"];
        [controller setMessageBody:[NSString stringWithFormat:@"%@", [_productInfo safeStringObjectForKey:@"name"]] isHTML:NO];
        
        if (_productDetailsCell.productImageView.image) {
            NSData *photoData = UIImageJPEGRepresentation(_productDetailsCell.productImageView.image, 1);
            [controller addAttachmentData:photoData mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"photo.png"]];
        }
        
        NSString* email = [UserDefaultsManager shared].email;
        if (email && [email isKindOfClass:[NSString class]]) {
            NSArray *toRecipients = [NSArray arrayWithObjects:email, nil];
            [controller setToRecipients:toRecipients];

        }
        
        [self presentModalViewController:controller animated:YES];
    } else {
        [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via Email"];
    }

}

- (void)twitterButtonClicked{
    [self loginToTwitter];
}

- (void)loadProfileInfo{
    
    [self showSpinnerWithName:@"ProductDetailViewController"];
    [ProductDetailsManager loadProfileInfoForUserIdNumber:[_productInfo safeNumberObjectForKey:@"user_id"]
                                                  success:^(NSNumber *userIdNumber, NSDictionary *profile) {
                                                      [self hideSpinnerWithName:@"ProductDetailViewController"];
                                                      _productDetailsCell.postedByLabel.text = [NSString
                                                                                                stringWithFormat:@"%@", [_productInfo safeStringObjectForKey:@"name"]];
                                                      [_productDetailsCell setPersonImageURLString:[profile safeStringObjectForKey:@"avatar_url"]];
                                                  }
                                                  failure:^(NSNumber *userIdNumber, NSError *error, NSString *errorString) {
                                                      [self hideSpinnerWithName:@"ProductDetailViewController"];
                                                      [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                          message:errorString];
                                                  }
                                                exception:^(NSNumber *userIdNumber, NSString *exceptionString) {
                                                    [self hideSpinnerWithName:@"ProductDetailViewController"];
                                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                                }];
}


- (void)loadComments{
    [self showSpinnerWithName:@"ProductDetailViewController"];
    [ProductDetailsManager loadCommentsForUser:[[_productInfo safeNumberObjectForKey:@"id"] stringValue]
                                       success:^(NSString *userId, NSArray *commests) {
                                           [self hideSpinnerWithName:@"ProductDetailViewController"];
                                           
                                           _tableArray = [self sortComments:commests];
                                           [_tableView reloadData];
                                           
                                       }
                                       failure:^(NSString *userId, NSError *error, NSString *errorString) {
                                           [self hideSpinnerWithName:@"ProductDetailViewController"];
                                           [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                               message:errorString];
                                       }
                                     exception:^(NSString *userId, NSString *exceptionString) {
                                         [self hideSpinnerWithName:@"ProductDetailViewController"];
                                         [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                     }];
    
}


- (void)loadStoreById:(NSString*)storeId{

    [self showSpinnerWithName:@"ProductDetailViewController"];
    [StoreDetailsManager loadStoreByStoreId:storeId
                                    success:^(NSDictionary* store) {
                                        [self hideSpinnerWithName:@"ProductDetailViewController"];
                                        [self showStoreWithInfo:store];
                                    }
                                    failure:^(NSError *error, NSString *errorString) {
                                        [self hideSpinnerWithName:@"ProductDetailViewController"];
                                        [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                            message:errorString];
                                    }
                                  exception:^(NSString *exceptionString) {
                                      [self hideSpinnerWithName:@"ProductDetailViewController"];
                                      [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                  }];
}

- (void)showStoreWithInfo:(NSDictionary*)store{
    StoreDetailViewController* storeDetailViewController = [StoreDetailViewController loadFromXIB_Or_iPhone5_XIB];
    storeDetailViewController.storeInfo = store;
    [self.navigationController pushViewController:storeDetailViewController animated:YES];
}

- (NSArray*)sortComments:(NSArray*)comments{
    
    NSArray* sorteArray = [comments sortedArrayUsingComparator: ^NSComparisonResult(id a, id b) {
        NSDate *d1 = [DataManager dateFromString:[a safeStringObjectForKey:@"created_at"]];
        NSDate *d2 = [DataManager dateFromString:[b safeStringObjectForKey:@"created_at"]];
        return [d2 compare: d1];
    }];
    return sorteArray;
}

- (void)likeProduct{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    [self showSpinnerWithName:@"ProductDetailViewController"];
    [ProductDetailsManager likeProducts:[[_productInfo safeNumberObjectForKey:@"id"] stringValue]
                                success:^{
                                    [self hideSpinnerWithName:@"ProductDetailViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                                                        message:@"Item liked successfully"];
                                    [LayoutManager shared].mainViewController.isNeedRefresh = YES;
                                }
                                failure:^(NSError *error, NSString *errorString) {
                                    [self hideSpinnerWithName:@"ProductDetailViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                        message:errorString];
                                }
                              exception:^(NSString *exceptionString) {
                                  [self hideSpinnerWithName:@"ProductDetailViewController"];
                                  [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                              }];
}

- (void)showWishlist{
    WishlistViewController* wishlistViewController = [WishlistViewController loadFromXIB_Or_iPhone5_XIB];
    wishlistViewController.productInfo = _productInfo;
    [self.navigationController pushViewController:wishlistViewController animated:YES];
}

- (void)createNewWishlistWithName:(NSString*)name{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self showSpinnerWithName:@"ProductDetailViewController"];
    [ProductDetailsManager createWishlist:name
                                  success:^{
                                      [self hideSpinnerWithName:@"ProductDetailViewController"];
                                      
                                      [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                          [self showWishlist];
                                      }
                                                                             title:@"Success"
                                                                           message:@"Wishlist created successfully"
                                                                 cancelButtonTitle:@"Ok"
                                                                 otherButtonTitles:nil];
                                  }
                                  failure:^(NSError *error, NSString *errorString) {
                                      [self hideSpinnerWithName:@"ProductDetailViewController"];
                                      [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                          message:errorString];
                                  }
                                exception:^(NSString *exceptionString) {
                                    [self hideSpinnerWithName:@"ProductDetailViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                }];
    
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
             
             [self postToWall:user.id];
             
         }else{
             [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
         }
     }];
}

- (void)postToWall:(NSString*)facebookId{
    
    NSString* imageUrl = [[_productInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"];
    NSString* description = [NSString stringWithFormat:@"%@\n %@",
                             _productDetailsCell.postedByLabel.text,
                             _productDetailsCell.storeNameLabel.text];
    
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

- (void)removeNotification{

    if ([[NotificationManager shared] isContainId:[_productInfo safeNumberObjectForKey:@"id"]]) {
        [NotificationManager removeNotifications:[_productInfo safeNumberObjectForKey:@"id"]
                                         success:^(id obj) {
                                             
                                         }
                                         failure:^(NSError *error, NSString *errorString) {
                                             
                                         }
                                       exception:^(NSString *exceptionString) {
                                           
                                       }];
    }
}

#pragma mark - Twitter
- (void)loginToTwitter{
    
    [[TwitterManager sharedInstance] setLoginSuccess:^(TwitterManager *twitterManager) {
        [self sendUpdate];
    }
                                             failure:^(TwitterManager *twitterManager, NSError *error) {
                                                 [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Login to Twitter failed"];
                                             }];
    
    UIViewController* oAuthTwitterController = [[TwitterManager sharedInstance] oAuthTwitterController];
    if (oAuthTwitterController) {
        
        [self presentModalViewController:oAuthTwitterController animated:YES];
    }else{
        [self sendUpdate];
    }
}

- (void)sendUpdate{
    
    [self showSpinnerWithName:@"ProductDetailViewController"];
    [TwitterManager loadTinyUrlForUrl:[[_productInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"]
                              success:^(NSString *tinyUrl) {
                                  [self hideSpinnerWithName:@"ProductDetailViewController"];
                                  
                                  NSString* name = [_productInfo safeStringObjectForKey:@"name"];
                                  name = [name stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
                                  NSString* text = [NSString stringWithFormat:@"Main And Me app\n%@\n%@", name, tinyUrl];
                                  [self sendUpdateWithMessage:text];
                              }
                              failure:^(NSError *error, NSString *errorString) {
                                  [self hideSpinnerWithName:@"ProductDetailViewController"];
                                  [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                      message:errorString];
                              }
                            exception:^(NSString *exceptionString) {
                                [self hideSpinnerWithName:@"ProductDetailViewController"];
                                [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                            }];
}

- (void)sendUpdateWithMessage:(NSString*)message{
    
    [self showSpinnerWithName:@"ProductDetailViewController"];
    [[TwitterManager sharedInstance] sendUpdate:message
                                        success:^(TwitterManager *manager) {
                                            [self hideSpinnerWithName:@"ProductDetailViewController"];
                                            static dispatch_once_t onceToken;
                                            dispatch_once(&onceToken, ^{
                                                [[AlertManager shared] showOkAlertWithTitle:@"Sucess"
                                                                                    message:@"Posted to Twitter successfuly"];
                                            });
                                        }
                                        failure:^(TwitterManager *manager, NSError *error) {
                                            [self hideSpinnerWithName:@"ProductDetailViewController"];
                                            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                message:@"Please wait few minutes, you can't post to twitter very often."];
                                        }exception:^(NSString* exceptionString){
                                            [self hideSpinnerWithName:@"ProductDetailViewController"];
                                            [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                        }];
}



@end
