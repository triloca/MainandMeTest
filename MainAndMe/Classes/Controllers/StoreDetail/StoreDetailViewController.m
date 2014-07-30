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
#import <QuartzCore/QuartzCore.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"
#import "AddCommentViewController.h"
#import "DescriptionCell.h"
#import "NotificationManager.h"

static NSString *kProductCellIdentifier = @"ProductCell";


@interface StoreDetailViewController ()
<UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* commentsTableArray;
@property (strong, nonatomic) NSArray* commentsArray;

@property (strong, nonatomic) StoreDetailsCell* storeDetailsCell;

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
    
    self.screenName = @"Store Details screen";

    // Do any additional setup after loading the view from its nib.
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Store details";
    
    _storeDetailsCell = [StoreDetailsCell loadViewFromXIB];
    
    NSString* imageUrl = [[_storeInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"];
    [_storeDetailsCell setProductImageURLString:imageUrl];
    
    _storeDetailsCell.postedByLabel.text = @"";
    _storeDetailsCell.storeNameLabel.text = [_storeInfo safeStringObjectForKey:@"name"];
    
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
    
    [_storeDetailsCell.commentButton addTarget:self
                                     action:@selector(commentButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
    
//    //! Fake Cell
//    _commentsTableArray = @[@{@"avatar_url":@"http://a0.twimg.com/profile_images/3429771169/3e5fedef81a3ab2a1cf57af04348d462_normal.png",
//                              @"body":@"Comments functionality will be available soon.",
//                              @"created_at":@"2013-03-28T14:02:09Z",
//                              @"username":@"Main And Me"}]; 
    
    [self loadProfileInfo];
  //  [self loadWithlist];
    [self loadProducts];
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
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapButtonClicked:(UIButton*)sender{
    StoreMapViewController* storeMapViewController = [StoreMapViewController loadFromXIB_Or_iPhone5_XIB];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[_storeInfo safeNumberObjectForKey:@"lat"] floatValue],
                                                                   [[_storeInfo safeNumberObjectForKey:@"lng"] floatValue]);
    storeMapViewController.coordinate = coordinate;
    storeMapViewController.storeInfo = _storeInfo;
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


- (void)commentButtonClicked:(UIButton*)sender{
   
    AddCommentViewController* addCommentViewController = [AddCommentViewController loadFromXIB_Or_iPhone5_XIB];
    addCommentViewController.productInfo = _storeInfo;
    addCommentViewController.isStoreState = YES;
    [self.navigationController pushViewController:addCommentViewController animated:YES];
    
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

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    UIColor* backColor = [UIColor colorWithRed:205/255.0f green:133/255.0f blue:63/255.0f alpha:0.7];
    [[actionSheet layer] setBackgroundColor:backColor.CGColor];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 368;
    }else if (indexPath.section == 1) {
        return [DescriptionCell cellHeight:[_storeInfo safeStringObjectForKey:@"description"]];
    }else if (indexPath.section == 2) {
        NSDictionary* object = [_commentsTableArray safeDictionaryObjectAtIndex:indexPath.row];
        return [CommentCell cellHeight:[object safeStringObjectForKey:@"body"]];
    }else if (indexPath.section == 3) {
        return 108;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        if ([[_storeInfo safeStringObjectForKey:@"description"] length] > 0) {
            return 1;
        }else{
            return 0;
        }
    }else if (section == 2) {
        return [_commentsTableArray count];
    }else if (section == 3) {
        NSInteger count = [_tableArray count];
        NSInteger temp = count % 3;
        NSInteger rowsCount = count / 3;
        if (temp > 0) {
            rowsCount++;
        }
        return rowsCount;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCommentCellIdentifier = @"CommentCell";
    static NSString *kDescriptionCellIdentifier = @"DescriptionCell";
    
    if (indexPath.section == 0) {
        return _storeDetailsCell;
    }else if (indexPath.section == 1){
        
        DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:kDescriptionCellIdentifier];
        
        if (cell == nil){
            cell = [DescriptionCell loadViewFromXIB];
        }
        
        // Configure the cell...
        
        [cell setMessageText:[_storeInfo safeStringObjectForKey:@"description"]];
        return cell;
        
    }else if (indexPath.section == 2){
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
        
        if (cell == nil){
            cell = [CommentCell loadViewFromXIB];
        }
        
        // Configure the cell...
        NSDictionary* object = [_commentsTableArray safeDictionaryObjectAtIndex:indexPath.row];
        
        [cell setMessageText:[object safeStringObjectForKey:@"body"]];
        [cell setCellData:object];
        return cell;
 
    }
    else if (indexPath.section == 3){
        
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

#pragma mark - Privat Methods

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
    
    NSNumber* userId = [_storeInfo safeNumberObjectForKey:@"user_id"];
    if (userId == nil) {
        return;
    }
    [self showSpinnerWithName:@"StoreDetailViewController"];
    
    [ProductDetailsManager loadProfileInfoForUserIdNumber:userId
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

- (void)loadComments{
    
    [self showSpinnerWithName:@"StoreDetailViewController"];
    [ProductDetailsManager loadStoreCommentsForUser:[[_storeInfo safeNumberObjectForKey:@"id"] stringValue]
                                            success:^(NSString *userId, NSArray *commests) {
                                                [self hideSpinnerWithName:@"StoreDetailViewController"];
                                                
                                                _commentsTableArray = [self sortComments:commests];
                                                [_tableView reloadData];
                                                
                                            }
                                            failure:^(NSString *userId, NSError *error, NSString *errorString) {
                                                [self hideSpinnerWithName:@"StoreDetailViewController"];
                                                [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                    message:errorString];
                                            }
                                          exception:^(NSString *userId, NSString *exceptionString) {
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

- (NSArray*)sortComments:(NSArray*)comments{
    
    NSArray* sorteArray = [comments sortedArrayUsingComparator: ^NSComparisonResult(id a, id b) {
        NSDate *d1 = [DataManager dateFromString:[a safeStringObjectForKey:@"created_at"]];
        NSDate *d2 = [DataManager dateFromString:[b safeStringObjectForKey:@"created_at"]];
        return [d2 compare: d1];
    }];
    return sorteArray;
}

- (void)removeNotification{
    
    if ([[NotificationManager shared] isContainId:[_storeInfo safeNumberObjectForKey:@"id"]]) {
        [NotificationManager removeNotifications:[_storeInfo safeNumberObjectForKey:@"id"]
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
   
    [self showSpinnerWithName:@"StoreDetailViewController"];
    [TwitterManager loadTinyUrlForUrl:[[_storeInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"]
                              success:^(NSString *tinyUrl) {
                                  [self hideSpinnerWithName:@"StoreDetailViewController"];
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
                                        }
                                      exception:^(NSString* exceptionString){
                                            [self hideSpinnerWithName:@"StoreDetailViewController"];
                                            [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                        }];
}

@end
