//
//  StoreDetailViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "StoreDetailViewController.h"
#import "ProductDetailsManager.h"
#import "StoreDetailsManager.h"
#import "UIView+Common.h"
#import "CommentCell.h"
#import "StoreDetailsCell.h"
#import "MBProgressHUD.h"
#import "AlertManager.h"
#import "DataManager.h"
#import "ProductCell.h"
#import "ProductDetailViewController.h"
#import "StoreMapViewController.h"
#import "ReachabilityManager.h"
#import "LayoutManager.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "UserDefaultsManager.h"
#import "RSTapRateView.h"
#import <QuartzCore/QuartzCore.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"


static NSString *kProductCellIdentifier = @"ProductCell";


@interface StoreDetailViewController ()
<UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
RSTapRateViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;

@property (strong, nonatomic) StoreDetailsCell* storeDetailsCell;
@property (strong, nonatomic) RSTapRateView* rateView;

@end

@implementation StoreDetailViewController

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
    // Do any additional setup after loading the view from its nib.
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Store details";
    
    _storeDetailsCell = [StoreDetailsCell loadViewFromXIB];
    
    NSString* imageUrl = [[_storeInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"];
    [_storeDetailsCell setProductImageURLString:imageUrl];
    
    _storeDetailsCell.postedByLabel.text = [_storeInfo safeStringObjectForKey:@"name"];
    _storeDetailsCell.storeNameLabel.text = [_storeInfo safeStringObjectForKey:@"street"];
    
    NSDate* date = [DataManager dateFromString:[_storeInfo safeStringObjectForKey:@"created_at"]];
    _storeDetailsCell.agoLabel.text = [DataManager howLongAgo:date];
    
    BOOL is_following = [[_storeInfo safeNumberObjectForKey:@"is_following"] boolValue];
    
    if (is_following) {
        _storeDetailsCell.followImageView.hidden = NO;
    }else{
        _storeDetailsCell.followImageView.hidden = YES;
    }

    [_storeDetailsCell.mapButton addTarget:self
                                    action:@selector(mapButtonClicked:)
                          forControlEvents:UIControlEventTouchUpInside];
    
    [_storeDetailsCell.likeButton addTarget:self
                                     action:@selector(likeButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
    
    [_storeDetailsCell.followButton addTarget:self
                                       action:@selector(followButtonClicked:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [_storeDetailsCell.shareButton addTarget:self
                                      action:@selector(shareButtonClicked:)
                            forControlEvents:UIControlEventTouchUpInside];
    
    [_storeDetailsCell.rateButton addTarget:self
                                     action:@selector(rateButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
    
    
  //  [self loadProfileInfo];
  //  [self loadWithlist];
    [self loadProducts];
    
}

- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapButtonClicked:(UIButton*)sender{
    StoreMapViewController* storeMapViewController = [StoreMapViewController new];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[_storeInfo safeNumberObjectForKey:@"lat"] floatValue],
                                                                   [[_storeInfo safeNumberObjectForKey:@"lng"] floatValue]);
    storeMapViewController.coordinate = coordinate;
    [self.navigationController pushViewController:storeMapViewController animated:YES];
}

- (void)likeButtonClicked:(UIButton*)sender{
    [self likeStore];
}

- (void)followButtonClicked:(UIButton*)sender{
    [self followStore];
}

- (void)shareButtonClicked:(id)sender {
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self
                                                         cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Email", @"SMS", nil];
    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}

- (void)rateButtonClicked:(UIButton*)sender{
    if (_rateView == nil) {
        [self showRateView];
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

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 368;
    }else{
        return 108;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    NSInteger count = [_tableArray count];
    NSInteger temp = count % 3;
    NSInteger rowsCount = count / 3;
    if (temp > 0) {
        rowsCount++;
    }
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return _storeDetailsCell;
    }else if (indexPath.section == 1){
        
        ProductCell* cell = [self productCellForIndexPath:indexPath];
        return cell;
        
    }
    return [[UITableViewCell alloc] init];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

#pragma mark - Rate Delegate
- (void)tapDidRateView:(RSTapRateView*)view rating:(NSInteger)rating{
    NSString* rateString = [NSString stringWithFormat:@"You rate this Sore %d star rate", rating];
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex == 0) {
            [self rateStore:rating];
        }
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             _rateView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [_rateView removeFromSuperview];
                             self.rateView = nil;
                         }];
        
    }
                                           title:@"Rate"
                                         message:rateString
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:@"Cancel", nil];
}
#pragma mark - Privat Methods

- (void)showRateView{

    self.rateView = [[RSTapRateView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x + 20, self.view.bounds.origin.y + 100, self.view.bounds.size.width - 40, 90.f)];
    _rateView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    _rateView.delegate = self;
    _rateView.alpha = 0;
    _rateView.layer.cornerRadius = 10;
    _rateView.layer.borderColor = [[UIColor grayColor] CGColor];
    _rateView.layer.borderWidth = 2.0f;
    [self.view addSubview:_rateView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         _rateView.alpha = 1;
    }];
}

- (void)sendSms{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            controller.body = [NSString stringWithFormat:@"%@", [_storeInfo safeStringObjectForKey:@"name"]];
            controller.messageComposeDelegate = self;
            [self presentModalViewController:controller animated:YES];
        } else {
            [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via SMS"];
            //  [[UIApplication sharedApplication] openURL: [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@",number]]];
        }
        
    }
}

- (void)sendMail {
    
    if ([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Recommendation for MainAndMe"];
        [controller setMessageBody:[NSString stringWithFormat:@"%@", [_storeInfo safeStringObjectForKey:@"name"]] isHTML:NO];
        
        if (_storeDetailsCell.productImageView.image) {
            NSData *photoData = UIImageJPEGRepresentation(_storeDetailsCell.productImageView.image, 1);
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


- (void)fBbuttonClicked{
    [self openFBSession];
}

- (void)twitterButtonClicked{
    [self loginToTwitter];
}

- (ProductCell*)productCellForIndexPath:(NSIndexPath*)indexPath{
    ProductCell *cell = [_tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier];
    
    if (cell == nil){
        cell = [ProductCell loadViewFromXIB];
        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
        
        cell.didClickAtIndex = ^(NSInteger selectedIndex){
            
            NSDictionary* itemData = [_tableArray safeDictionaryObjectAtIndex:selectedIndex];
            [self showProductDetailsWithInfo:itemData];
        };
    }
    
    // Configure the cell...
    
    NSInteger index = indexPath.row * 3;
    
    if ([_tableArray count] > index) {
        
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index];
        NSString* imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
        [cell.firstView setImageURLString:imageUrl];
        cell.firstView.hidden = NO;
    }else{
        cell.firstView.hidden = YES;
    }
    cell.firstView.coverButton.tag = index;
    
    if ([_tableArray count] > index + 1) {
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index + 1];
        NSString* imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        [cell.secondView setImageURLString:imageUrl];
        cell.secondView.hidden = NO;
    }else{
        cell.secondView.hidden = YES;
    }
    cell.secondView.coverButton.tag = index + 1;
    
    if ([_tableArray count] > index + 2) {
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index + 2];
        NSString* imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        [cell.thirdView setImageURLString:imageUrl];
        cell.thirdView.hidden = NO;
    }else{
        cell.thirdView.hidden = YES;
    }
    cell.thirdView.coverButton.tag = index + 2;
    
    return cell;
}


- (void)showProductDetailsWithInfo:(NSDictionary*)data{
    
    ProductDetailViewController* productDetailViewController = [ProductDetailViewController loadFromXIB_Or_iPhone5_XIB];
    productDetailViewController.productInfo = data;
    [self.navigationController pushViewController:productDetailViewController animated:YES];
    
}

- (void)loadProfileInfo{
    
    [self showSpinnerWithName:@"StoreDetailViewController"];
    
    [ProductDetailsManager loadProfileInfoForUserIdNumber:[_storeInfo safeNumberObjectForKey:@"user_id"]
                                                  success:^(NSNumber *userIdNumber, NSDictionary *profile) {
                                                      [self hideSpinnerWithName:@"StoreDetailViewController"];
                                                      _storeDetailsCell.postedByLabel.text = [NSString
                                                                                                stringWithFormat:@"Posted By %@ in", [profile safeStringObjectForKey:@"name"]];
                                                      [_storeDetailsCell setPersonImageURLString:[profile safeStringObjectForKey:@"avatar_url"]];
                                                  }
                                                  failure:^(NSNumber *userIdNumber, NSError *error, NSString *errorString) {
                                                      [self hideSpinnerWithName:@"StoreDetailViewController"];
                                                      [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                          message:errorString];
                                                  }
                                                exception:^(NSNumber *userIdNumber, NSString *exceptionString) {
                                                    [self hideSpinnerWithName:@"StoreDetailViewController"];
                                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                                }];
    
}

- (void)loadProducts{
    
    [self showSpinnerWithName:@"StoreDetailViewController"];
    [StoreDetailsManager loadProductsForStore:[[_storeInfo safeNumberObjectForKey:@"id"] stringValue]
                                      success:^(NSArray *products) {
                                          [self hideSpinnerWithName:@"StoreDetailViewController"];
                                          _tableArray = products;
                                          [_tableView reloadData];
                                      }
                                      failure:^(NSError *error, NSString *errorString) {
                                          [self hideSpinnerWithName:@"StoreDetailViewController"];
                                          [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                              message:errorString];
                                      }
                                    exception:^(NSString *exceptionString) {
                                        [self hideSpinnerWithName:@"StoreDetailViewController"];
                                        [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                    }];
    
}

- (void)likeStore{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    [self showSpinnerWithName:@"StoreDetailViewController"];
    [StoreDetailsManager likeStore:[[_storeInfo safeNumberObjectForKey:@"id"] stringValue]
                                success:^{
                                    [self hideSpinnerWithName:@"StoreDetailViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                                                        message:@"Store liked successfully"];
                                    [LayoutManager shared].mainViewController.isNeedRefresh = YES;
                                }
                                failure:^(NSError *error, NSString *errorString) {
                                    [self hideSpinnerWithName:@"StoreDetailViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                        message:errorString];
                                }
                              exception:^(NSString *exceptionString) {
                                  [self hideSpinnerWithName:@"StoreDetailViewController"];
                                  [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                              }];
}

- (void)followStore{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    [self showSpinnerWithName:@"StoreDetailViewController"];
    [StoreDetailsManager followStore:[[_storeInfo safeNumberObjectForKey:@"id"] stringValue]
                             success:^{
                                 [self hideSpinnerWithName:@"StoreDetailViewController"];
                                 [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                                                     message:@"Store followed successfully"];
                                 _storeDetailsCell.followImageView.hidden = NO;
                                 [LayoutManager shared].mainViewController.isNeedRefresh = YES;
                             }
                             failure:^(NSError *error, NSString *errorString) {
                                 [self hideSpinnerWithName:@"StoreDetailViewController"];
                                 [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                     message:errorString];
                             }
                           exception:^(NSString *exceptionString) {
                               [self hideSpinnerWithName:@"StoreDetailViewController"];
                               [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                           }];
}

- (void)rateStore:(NSInteger)rate{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self showSpinnerWithName:@"StoreDetailViewController"];
    [StoreDetailsManager rateStore:[[_storeInfo safeNumberObjectForKey:@"id"] stringValue]
                              rate:rate
                           success:^{
                               [self hideSpinnerWithName:@"StoreDetailViewController"];
                               [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                                                   message:@"Store rated successfully"];
                               _storeDetailsCell.followImageView.hidden = NO;
                               [LayoutManager shared].mainViewController.isNeedRefresh = YES;
                           }
                           failure:^(NSError *error, NSString *errorString) {
                               [self hideSpinnerWithName:@"StoreDetailViewController"];
                               [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                   message:errorString];
                           }
                         exception:^(NSString *exceptionString) {
                             [self hideSpinnerWithName:@"StoreDetailViewController"];
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
        [self showSpinnerWithName:@"StoreDetailViewController"];
        [FBSession openActiveSessionWithPublishPermissions:permissions
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             [self hideSpinnerWithName:@"StoreDetailViewController"];
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
    [self showSpinnerWithName:@"StoreDetailViewController"];
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection, id <FBGraphUser> user, NSError *error) {
         [self hideSpinnerWithName:@"StoreDetailViewController"];
         if (!error) {

             [self postToWall:user.id];
             
         }else{
             [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
         }
     }];
}

- (void)postToWall:(NSString*)facebookId{
    
    NSString* imageUrl = [[_storeInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"];
    NSString* description = [NSString stringWithFormat:@"%@\n %@",
                             [_storeInfo safeStringObjectForKey:@"name"],
                             [_storeInfo safeStringObjectForKey:@"street"]];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"254708664663458", @"app_id",
                                   @"http://mainandme-staging-s.herokuapp.com", @"link",
                                   imageUrl, @"picture",
                                   @"Main And Me", @"name",
                                   @"Store", @"caption",
                                   description, @"description",
                                   @"Main And Me application",  @"message",
                                   nil];
    
    
    [self showSpinnerWithName:@"StoreDetailViewController"];
    
    //Post to wall.
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", facebookId]
                                 parameters:params HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         [self hideSpinnerWithName:@"StoreDetailViewController"];
         
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
   
    [TwitterManager loadTinyUrlForUrl:[[_storeInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"]
                              success:^(NSString *tinyUrl) {
                                  NSString* name = [_storeInfo safeStringObjectForKey:@"name"];
                                  name = [name stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
                                  NSString* text = [NSString stringWithFormat:@"Main And Me app\n%@\n%@", name, tinyUrl];
                                  [self sendUpdateWithMessage:text];
                              }
                              failure:^(NSError *error, NSString *errorString) {
                                  [self hideSpinnerWithName:@"StoreDetailViewController"];
                                  [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                      message:errorString];
                              }
                            exception:^(NSString *exceptionString) {
                                [self hideSpinnerWithName:@"StoreDetailViewController"];
                                [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                            }];
}

- (void)sendUpdateWithMessage:(NSString*)message{
    
    [self showSpinnerWithName:@"StoreDetailViewController"];
    [[TwitterManager sharedInstance] sendUpdate:message
                                        success:^(TwitterManager *manager) {
                                            [self hideSpinnerWithName:@"StoreDetailViewController"];
                                            static dispatch_once_t onceToken;
                                            dispatch_once(&onceToken, ^{
                                                [[AlertManager shared] showOkAlertWithTitle:@"Sucess"
                                                                                    message:@"Posted to Twitter successfuly"];
                                            });
                                        }
                                        failure:^(TwitterManager *manager, NSError *error) {
                                            [self hideSpinnerWithName:@"StoreDetailViewController"];
                                        }];
}

@end
