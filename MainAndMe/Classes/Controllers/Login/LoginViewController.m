//
//  LoginViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "NSString+Common.h"
#import "AlertManager.h"
#import "LoginSignUpManager.h"
#import "DataManager.h"
#import "UserDefaultsManager.h"
#import "MBProgressHUD.h"
#import "ReachabilityManager.h"
#import "TwitterManager.h"


@interface LoginViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *emailTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *passwordTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) BOOL isKeyBoardVisible;
@end

@implementation LoginViewController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self checkLastLogin];
}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action

- (IBAction)loginButtonClicked:(id)sender {
    if ([self isTextFieldsValid]) {
        [self hideKeyBoard];
        [self standardLoginWith:_emailTextField.text password:_passwordTextField.text];
    }
}
- (IBAction)facebookButtonClicked:(id)sender {
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    [self openFBSession];
}
- (IBAction)twitterButtonClicked:(id)sender {
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    [self loginToTwitter];

}
- (IBAction)createAccountButtonClicked:(id)sender {
    
    [self hideKeyBoard];
    
    SignUpViewController* signUpViewController = [SignUpViewController loadFromXIB_Or_iPhone5_XIB];
    [self.navigationController pushViewController:signUpViewController animated:YES];
}

- (IBAction)forgotPasswordButtonClicked:(id)sender {
    [self hideKeyBoard];
    
    if (_emailTextField.text.length == 0) {
        [[AlertManager shared] showOkAlertWithTitle:@"Enter Email address"];
        [_emailTextField becomeFirstResponder];
        return;
    }
    if (![_emailTextField.text isValidEmail]) {
        [[AlertManager shared] showOkAlertWithTitle:@"Enter valid Email"];
        [_emailTextField becomeFirstResponder];
        return;
    }
    
    [self forgotPasswordRequest];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self scrollToTextField:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _emailTextField) {
        [_passwordTextField becomeFirstResponder];
    }else if (textField == _passwordTextField) {
        [_passwordTextField resignFirstResponder];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return YES;
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

#pragma mark - Privat Methods
- (void)updateContentSize{
    CGFloat height = _scrollView.frame.size.height;
    if (_isKeyBoardVisible) {
        [_scrollView setContentSize:CGSizeMake(0, height + 216)];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            [_scrollView setContentSize:CGSizeMake(0, height)];
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        } completion:^(BOOL finished) {
            
        }];
    }
}


- (void)scrollToTextField:(UITextField*)textField{
    if (textField == _emailTextField) {
        [_scrollView setContentOffset:CGPointMake(0, 20) animated:YES];
    }else if (textField == _passwordTextField) {
        [_scrollView setContentOffset:CGPointMake(0, 20) animated:YES];
    }
}

- (void)hideKeyBoard{
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (BOOL)isTextFieldsValid{
    
    if (![_emailTextField.text isValidEmail]) {
        [[AlertManager shared] showAlertWithCallBack:nil
                                               title:@"Invalid email"
                                             message:nil
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];
        return NO;
    }
    if (_passwordTextField.text.length == 0) {
        [[AlertManager shared] showAlertWithCallBack:nil
                                               title:@"Please enter password"
                                             message:nil
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];

        return NO;
    }
    return YES;
}

- (void)checkLastLogin{

    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    NSString* lastLoginType = [[UserDefaultsManager shared] lastLoginType];
    if ([lastLoginType isEqualToString:kLoginTypeStandard]) {
        [self standardLoginWith:[[UserDefaultsManager shared] email]
                       password:[[UserDefaultsManager shared] password]];
    }else if ([lastLoginType isEqualToString:kLoginTypeViaFacebook]) {
        
        [self authenticaeThroughFacebook:[[UserDefaultsManager shared] userId]
                                userName:[[UserDefaultsManager shared] userName]
                                   email:[[UserDefaultsManager shared] email]
                             accessToken:[FBSession activeSession].accessTokenData.accessToken];
        
    }else if ([lastLoginType isEqualToString:kLoginTypeViaTwitter]) {
        [self authenticaeThroughTwitter:[[UserDefaultsManager shared] userId]
                               userName:[[UserDefaultsManager shared] userName]
                                  email:[[UserDefaultsManager shared] email]
                              authtoken:[[UserDefaultsManager shared] authtoken]];
    }
}


- (void)standardLoginWith:(NSString*)email password:(NSString*)password{

    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [LoginSignUpManager loginWithEmail:email
                              password:password
                               success:^(NSDictionary *user) {
                                   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                
                                   [self.navigationController popViewControllerAnimated:NO];
                               }
                               failure:^(NSError *error, NSString *errorString) {
                                   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                   [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                       message:errorString];
                               }
                             exception:^(NSString *exceptionString) {
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                             }];

}


- (void)forgotPasswordRequest{

    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [LoginSignUpManager forgotPasswordForEmail:_emailTextField.text
                                       success:^{
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                           [[AlertManager shared] showOkAlertWithTitle:@"Password was reset successfully" message:@"Please check your Email"];
                                           [[UserDefaultsManager shared] clearOldLoginSettings];
                                       }
                                       failure:^(NSError *error, NSString *errorString) {
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                           [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                               message:errorString];
                                       }
                                     exception:^(NSString *exceptionString) {
                                         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                         [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                     }];

}


#pragma mark - Facebook

- (void)openFBSession {
    
    NSArray* permissions = [[NSArray alloc] initWithObjects:@"publish_stream",@"email", nil];
    [FBSession.activeSession closeAndClearTokenInformation];
    
    if (FBSession.activeSession.isOpen) {
        [self loadMeFacebook];
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
    
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection, id <FBGraphUser> user, NSError *error) {
         if (!error) {
             NSString* userName = user.name;
             NSString* user_id = user.id;
             NSString* email = [user objectForKey:@"email"];
             
             [self authenticaeThroughFacebook:user_id
                                     userName:userName
                                        email:email
                                  accessToken:[FBSession activeSession].accessTokenData.accessToken];
             
         }else{
             [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Facebook fail"];
         }
     }];
}

- (void)authenticaeThroughFacebook:(NSString*)user_id
                          userName:(NSString*)userName
                             email:(NSString*)email
                       accessToken:(NSString*)accessToken{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    if (userName == nil || userName.length == 0 || [userName isEqualToString:@"(null)"]) {
        userName = @"";
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [LoginSignUpManager loginViaSocialWithUserId:user_id
                                     accessToken:accessToken
                                       authtoken:nil
                                           email:email
                                        username:userName
                                            type:@"facebook"
                                         success:^(NSString *userId, NSString *api_token) {
                                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                             [self.navigationController popViewControllerAnimated:NO];
                                         }
                                         failure:^(NSError *error, NSString *errorString) {
                                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                             [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                 message:errorString];
                                         }
                                       exception:^(NSString *exceptionString) {
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                           [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                       }];
}

#pragma mark - Twitter

- (void)loginToTwitter{
 
    [[TwitterManager sharedInstance] setLoginSuccess:^(TwitterManager *twitterManager) {
       [self showEmailAlert];
    }
                                             failure:^(TwitterManager *twitterManager, NSError *error) {
                                                 NSLog(@"Login to Twitter failed");
                                             }];
    
    UIViewController* oAuthTwitterController = [[TwitterManager sharedInstance] oAuthTwitterController];
    if (oAuthTwitterController) {
        
        [self presentModalViewController:oAuthTwitterController animated:YES];
    }else{
        [self showEmailAlert];
    }
}



- (void)openTwitterSession{
 
//    UIViewController *controller =
//    [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:[TwitterManager shared].engine
//                                                                    delegate:self];
//    
//    if (controller) {
//        [self.navigationController presentModalViewController:controller animated:YES];
//    }
//    else {
//        [self showEmailAlert];
//    }
//
}

- (void)showEmailInvalidAlert{
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self showEmailAlert];
    }
                                           title:@"Error"
                                         message:@"Invalid email, try again"
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil];
}


- (void)showEmailAlert {
    [[AlertManager shared] showTextFieldAlertWithCallBack:^(UIAlertView *alertView, UITextField *textField, NSInteger buttonIndex) {
        [textField resignFirstResponder];
        
        if (buttonIndex == 1) {
            if ([textField.text isValidEmail]) {
                [self authenticaeThroughTwitter:textField.text];
            }else{
                [self showEmailInvalidAlert];
            }
        
        }
     
        
    }
                                                    title:@"Enter your account email"
                                                  message:@"Email"
                                              placeholder:@"Enter email"
                                                   active:YES
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Ok", nil];

}


- (void)authenticaeThroughTwitter:(NSString*)email{

    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }

    
    [self authenticaeThroughTwitter:[[UserDefaultsManager shared] userId]
                           userName:[[UserDefaultsManager shared] userName]
                              email:email
                          authtoken:[[UserDefaultsManager shared] authtoken]];
}

- (void)authenticaeThroughTwitter:(NSString*)user_id
                         userName:(NSString*)userName
                            email:(NSString*)email
                        authtoken:(NSString*)authtoken{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    if (userName == nil || userName.length == 0 || [userName isEqualToString:@"(null)"]) {
        userName = @"";
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [LoginSignUpManager loginViaSocialWithUserId:user_id
                                     accessToken:nil
                                       authtoken:authtoken
                                           email:email
                                        username:userName
                                            type:@"twitter"
                                         success:^(NSString *userId, NSString *api_token) {
                                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                             [self.navigationController popViewControllerAnimated:NO];
                                         }
                                         failure:^(NSError *error, NSString *errorString) {
                                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                             [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                 message:errorString];
                                         }
                                       exception:^(NSString *exceptionString) {
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                           [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                       }];
}




- (void)storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username {
    NSLog(@"data = %@", data);
    NSLog(@"username = %@", username);
    
    NSArray *firstSplit = [data componentsSeparatedByString:@"&"];
    //    NSLog(@"%@",[[firstSplit objectAtIndex:2] objectForKey:@"user_id"]);
    NSArray *secondsplit = [[firstSplit objectAtIndex:2] componentsSeparatedByString:@"="];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:data forKey:@"authData"];
    [defaults setObject:username forKey:@"twittername"];
    [defaults setObject:[secondsplit objectAtIndex:1] forKey:@"userId"];
    
    NSLog(@"%@", username);
    [defaults synchronize];
    
    [self showEmailAlert];
    //	NSString *Str=[_engine getUserInformationFor:username];
    //	NSLog(@"%@",Str);
   
    
//    for (UIButton *customButton in customButtons) {
//        customButton.layer.cornerRadius = 5.0f;
//        customButton.clipsToBounds = YES;
//    }
}

- (NSString *)cachedTwitterOAuthDataForUsername:(NSString *)username {
    NSLog(@"%@", username);
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"twittername"]);
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"authData"];
}

@end
