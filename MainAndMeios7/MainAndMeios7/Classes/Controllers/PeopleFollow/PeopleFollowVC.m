//
//  PeopleFollowVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 16.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PeopleFollowVC.h"
#import "CustomTitleView.h"
#import "PeopleCell.h"
#import "FollowingsRequest.h"
#import "FacebookManager.h"



@interface PeopleFollowVC () <UITableViewDataSource, UITableViewDelegate, FBFriendPickerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UIView *emptyView;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@end

@implementation PeopleFollowVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_plus_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(plusButtonAction)];
    
    __weak PeopleFollowVC* wSelf = self;
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"Places I Follow" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        [[LayoutManager shared] showHomeControllerAnimated:YES];
        [wSelf.navigationController popToRootViewControllerAnimated:YES];

    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PeopleCell" bundle:nil] forCellReuseIdentifier:@"PeopleCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(reload)
                  forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:self.refreshControl];
//    [self loadTable];
}

- (void) reload {
    [self loadFollowings];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showSpinnerWithName:@""];
    [self loadFollowings];
}

- (void) endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void) loadFollowings {
    [self endRefreshing];
    FollowingsRequest *request = [FollowingsRequest new];
    request.userId = [CommonManager shared].userId;
    request.followableType = FollowableStore;
    //http://mainandme.com/api/v1/users/3/follows/followings/store?_token=n9Mn4Nr1Lgw8cxsgry9R
    __weak PeopleFollowVC *wself = self;
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(FollowingsRequest *request) {
        wself.items = request.followings;
        [wself loadTable];
        [wself endRefreshing];
        [wself hideAllSpiners];
    } failure:^(id _request, NSError *error) {
        [[AlertManager shared] showOkAlertWithTitle:@"Main and me" message:error.localizedDescription];
        [wself hideAllSpiners];
        [wself endRefreshing];
    }];
}


- (void) loadTable {
    [self.tableView reloadData];
    if (_items.count == 0) {
        [UIView animateWithDuration:0.3 animations:^() {
            _tableView.tableHeaderView = _emptyView;
            _emptyView.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^() {;
            _emptyView.alpha = 0;
        } completion:^(BOOL finished) {
            _tableView.tableHeaderView = nil;
        }] ;
    }
}

- (void) anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

#pragma mark - Facebook


- (IBAction)pickFriendsButtonClick:(id)sender {
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              [self pickFriendsButtonClick:sender];
                                          }
                                      }];
        return;
    }
    
    //[self shareDialog];
    //[self loadFriends];
    
    //return;
    
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    NSArray* users = self.friendPickerController.selection;
    
    [self shareDialogForUsers:users];
    [self shareDialog];
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<Cancelled>"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
   // self.selectedFriendsView.text = text;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}



- (void) plusButtonAction {
    
    [self pickFriendsButtonClick:nil];
    
    return;
    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link =
    [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    params.name = @"Message Dialog Tutorial";
    params.caption = @"Build great social apps that engage your friends.";
    params.picture = [NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
    params.linkDescription = @"Send links from your app using the iOS SDK.";
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentMessageDialogWithParams:params]) {
        // Enable button or other UI to initiate launch of the Message Dialog
        NSLog(@"can present");
    }  else {
        // Disable button or other UI for Message Dialog
        NSLog(@"cannot present");
    }
    [FBDialogs presentMessageDialogWithLink:[NSURL URLWithString:@"https://developers.facebook.com/ios"]
                                    handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                        if(error) {
                                            // An error occurred, we need to handle the error
                                            // See: https://developers.facebook.com/docs/ios/errors
                                            NSLog([NSString stringWithFormat:@"Error messaging link: %@", error]);
                                        } else {
                                            // Success
                                            NSLog(@"result %@", results);
                                        }
                                    }];
}

- (void)loadFriends{

    [[FacebookManager shared] loadFriendsForUser:@"me"
                                       pagingURL:nil
                                         success:^(NSArray *friends, NSString *nextPage, NSString *prevPage) {
                                             
                                         }
                                         failure:^(FBRequestConnection *connection, id result, NSError *error) {
                                             
                                         }];

}

- (void)shareDialogForUsers:(NSArray*)users{

    [users enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]){
            [self postToWall:[obj safeStringObjectForKey:@"id"]];
        }
    }];
    
}

- (void)postToWall:(NSString*)facebookId{
    return;
    NSString* imageUrl = @"http://www.mainandme.com/assets/logo-b1b6682a45a5b3738e68b7b03b9eb0db.png";
    NSString* description = @"Main And Me";
    
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
             [[AlertManager shared] showOkAlertWithTitle:@"Success" message:@"Posted to Facebook successfuly"];
         }
         
     }];
    
}



- (void)shareDialog{
    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link =
    [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    params.name = @"Message Dialog Tutorial";
    params.caption = @"Build great social apps that engage your friends.";
    params.picture = [NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
    params.linkDescription = @"Send links from your app using the iOS SDK.";
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentMessageDialogWithParams:params]) {
        // Enable button or other UI to initiate launch of the Message Dialog
        NSLog(@"can present");
    }  else {
        // Disable button or other UI for Message Dialog
        NSLog(@"cannot present");
    }
    [FBDialogs presentMessageDialogWithLink:[NSURL URLWithString:@"https://developers.facebook.com/ios"]
                                    handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                        if(error) {
                                            // An error occurred, we need to handle the error
                                            // See: https://developers.facebook.com/docs/ios/errors
                                            NSLog([NSString stringWithFormat:@"Error messaging link: %@", error]);
                                        } else {
                                            // Success
                                            NSLog(@"result %@", results);
                                        }
                                    }];

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

//- (void)postToWall:(NSString*)facebookId{
//    
//    NSString* imageUrl = @"";//[[_product safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
//    NSString* description = @"";//[NSString stringWithFormat:@"%@\n %@",
//                             //[_product safeStringObjectForKey:@"name"],
//                             //[_product safeStringObjectForKey:@"description"]];
//    
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"254708664663458", @"app_id",
//                                   @"http://mainandme-staging-s.herokuapp.com", @"link",
//                                   imageUrl, @"picture",
//                                   @"Main And Me", @"name",
//                                   @"Product", @"caption",
//                                   description, @"description",
//                                   @"Main And Me application",  @"message",
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
//    
//}


#pragma mark - TableView

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PeopleCell *cell = (PeopleCell *) [tableView dequeueReusableCellWithIdentifier:@"PeopleCell"];
    
    [cell setUser:_items[indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* user = _items[indexPath.row];
    
    ProfileVC* vc = [ProfileVC loadFromXIBForScrrenSizes];
    vc.user = user;
    vc.userID = [user safeNumberObjectForKey:@"id"];
    vc.isMenu = NO;
    vc.isEditable = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
