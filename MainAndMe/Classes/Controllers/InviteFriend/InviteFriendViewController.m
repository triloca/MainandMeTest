//
//  InviteFriendViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "InviteFriendViewController.h"
#import "UIView+Common.h"
#import "AlertManager.h"
#import "FriendCell.h"
#import "FacebookSDK/FacebookSDK.h"
#import "SBJSON.h"




@interface InviteFriendViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* friendsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (assign, nonatomic) BOOL isKeyBoardVisible;

@end

@implementation InviteFriendViewController

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
    _titleTextLabel.text = @"Invite Friends";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self openFBSession];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [self setSearchTextField:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kFriendCellIdentifier = @"FriendCell";
    
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCellIdentifier];
    
    if (cell == nil){
        cell = [FriendCell loadViewFromXIB];
    }
    
    // Configure the cell...
    
    NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    cell.nameLabel.text = [object safeStringObjectForKey:@"name"];
     NSString* photoUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [object safeStringObjectForKey:@"id"]];
    [cell setPersonImageURLString:photoUrl];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    NSString* friendId = [object safeStringObjectForKey:@"id"];
    [self inviteFriendWithId:friendId];

}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField.text length] > 0) {
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)didChangeValue:(UITextField *)sender {
    [self applyFilterWith:sender.text];
}

#pragma mark - Privat Methods


- (void)updateContentSize{// to privat
    
    if (_isKeyBoardVisible) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height -= 160;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height += 160;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)applyFilterWith:(NSString*)name{
    
    if ([name isEqualToString:@""]) {
        _tableArray = [self sortAddresses:_friendsArray];
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    
    NSArray *searchNames = [[name lowercaseString]componentsSeparatedByString: @" "];
    NSString *firstSearchName = [[searchNames objectAtIndex: 0] lowercaseString];
    NSString *secondSearchName =nil;
    if(searchNames.count>1)secondSearchName =[[searchNames objectAtIndex: 1] lowercaseString];
    
    
    
    for (NSDictionary* friend in _friendsArray) {
        
        NSString* fixedName =[[friend objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"  " withString:@" "];//some names are separated by double space :(
        
        NSArray *names = [fixedName componentsSeparatedByString: @" "];
        
        NSString *firstName = nil;
        NSString *secondName = nil;
        if ([names count] > 0) {
            firstName = [[names objectAtIndex: 0] lowercaseString];
        }
        if ([names count] > 1) {
            secondName = [[names objectAtIndex: 1] lowercaseString];
        }
        //  NSLog(@"|%@|,|%@|,|%@|",person.name,firstName,secondName);
        if(secondSearchName == nil || secondSearchName.length==0){//search by one name
            if ([firstName hasPrefix: firstSearchName] || [secondName hasPrefix: firstSearchName]) {
                [filterdMutableArray addObject:friend];
            }
        }
        else{
            if ( ([firstName hasPrefix: firstSearchName] && [secondName hasPrefix: secondSearchName])
                || ([firstName hasPrefix: secondSearchName] && [secondName hasPrefix: firstSearchName]) ) {//both searchNames must be contained
                [filterdMutableArray addObject:friend];
            }
        }
        
    }
    _tableArray = [NSArray arrayWithArray:filterdMutableArray];
    [_tableView reloadData];
    
}

- (NSArray*)sortAddresses:(NSArray*)array{
    NSArray *sorteArray = [array sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = [a safeStringObjectForKey:@"name"];
        NSString *second = [b safeStringObjectForKey:@"name"];
        return [first caseInsensitiveCompare:second];
    }];
    
    return sorteArray;

}

- (void)inviteFriendWithId:(NSString*)friendId{
   
    [_searchTextField resignFirstResponder];
    
    NSMutableDictionary *params =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"Main And Me for iOS", @"name",
     @"Main and Me is 100% dedicated to local, independent business.", @"description",
     @"http://mainandme-test.herokuapp.com", @"link",
     @"http://mainandme-staging-s.herokuapp.com/assets/logo.png", @"picture",
     nil];
    
    [params setObject:friendId forKey:@"to"];
    
    [FBWebDialogs presentFeedDialogModallyWithSession:FBSession.activeSession
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL,NSError *error)
     {
         [_tableView reloadData];
         switch (result) {
             case FBWebDialogResultDialogCompleted:{
                 [[AlertManager shared] showOkAlertWithTitle:@"Success" message:@"Invited successfully"];
                 break;
             }
             case FBWebDialogResultDialogNotCompleted:{
                 [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Invitation Failed"];
                 break;
             }
                 
             default:
                 break;
         }
         
         if (error) {
             [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Invitation Failed"];
         }
     }];
}

#pragma mark - Facebook

- (void)openFBSession {
    
    NSArray* permissions = [[NSArray alloc] initWithObjects:@"publish_stream",@"email", nil];
    [FBSession.activeSession closeAndClearTokenInformation];
    
    if (FBSession.activeSession.isOpen) {
        [self loadMeFriends];
    } else {
        
        [FBSession openActiveSessionWithPublishPermissions:permissions
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             [self sessionStateChanged:session state:status error:error];
                                         }];
        
    }
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            [self loadMeFriends];
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

- (void)loadMeFriends {
    
    [self showSpinnerWithName:@"Facebook"];
    FBRequest* request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                  graphPath:@"me/friends?limit=1000"];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [self hideSpinnerWithName:@"Facebook"];
        if (!error) {
            if ([result isKindOfClass:[NSDictionary class]]) {
                _friendsArray = [result safeArrayObjectForKey:@"data"];
                [self applyFilterWith:@""];
            }
        }else{
            [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Facebook fail"];
        }
        
    }];
}

#pragma mark - Keyboard Notificastion

- (void)keyboardWillShow:(NSNotification*)nitif{
    _isKeyBoardVisible = YES;
    [self updateContentSize];
}


- (void)keyboardWillHide:(NSNotification*)nitif{
    _isKeyBoardVisible = NO;
    [self updateContentSize];
}

@end
