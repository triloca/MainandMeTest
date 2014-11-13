//
//  LoginVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/1/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoginVC.h"
#import "LoginRequest.h"
#import "ForgetPasswordVC.h"
#import "FacebookManager.h"
#import "LoginViaSocialRequest.h"
#import "TwitterManager.h"
#import "NSString+Email.h"

@interface LoginVC()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIView *viewEmailPassword;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@end


@implementation LoginVC

#pragma mark _______________________ Class Methods _________________________


+ (void)loginVCPresentation:(void (^)(LoginVC* loginVC))presentation
                    success:(void (^)(LoginVC* loginVC, NSString* token))success
                    failure:(void (^)(LoginVC* loginVC, NSError* error))failure
            alreadyLoggedIn:(void (^)(LoginVC* loginVC, NSString* token))alreadyLoggedIn{
    
    LoginVC* loginVC = [LoginVC loadFromXIB_Or_iPhone5_XIB];
    loginVC.successBlock = success;
    loginVC.failureBlock = failure;
    loginVC.alreadyLoggedInBlock = alreadyLoggedIn;
    
    if ([[CommonManager shared] isLoggedIn]) {
        alreadyLoggedIn(loginVC, [[CommonManager shared] apiToken]);
    }else{
        presentation(loginVC);
    }
}

#pragma mark ____________________________ Init _____________________________

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization

    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


- (void)dealloc{

}

#pragma mark _______________________ View Lifecycle ________________________

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewEmailPassword.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"signin_fields_back.png"]];
    self.navigationController.navigationBarHidden=YES;
    
    CGRect frame=[UIScreen mainScreen].bounds;
    imgMainBackground.frame=frame;
    [imgMainBackground setImage:[UIImage imageNamed:@"signin_background.png"]];
    
    [self SetViewFrames];
    
}

-(void)SetViewFrames{
    
    if (IS_IPHONE_4_OR_LESS) {
        CGRect frame=imgLogo.frame;
        frame.origin.y=frame.origin.y-40;
        imgLogo.frame=frame;
        
        frame=imgSeperator.frame;
        frame.origin.y-=40;
        imgSeperator.frame=frame;
        
        frame=viewSignUp.frame;
        frame.origin.y-=40;
        viewSignUp.frame=frame;
        
        frame=self.viewEmailPassword.frame;
        frame.origin.y-=40;
        self.viewEmailPassword.frame=frame;
        
        frame=self.loginButton.frame;
        frame.origin.y-=40;
        self.loginButton.frame=frame;
        
        frame=self.facebookButton.frame;
        frame.origin.y-=40;
        self.facebookButton.frame=frame;
        
        frame=self.twitterButton.frame;
        frame.origin.y-=40;
        self.twitterButton.frame=frame;
    }
}


- (void)loginWithEmail:(NSString*)email
                  pass:(NSString*)pass{
    
    LoginRequest *loginRequest = [[LoginRequest alloc] init];
    loginRequest.email = email;
    loginRequest.password = pass;
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:loginRequest success:^(LoginRequest *_loginRequest) {
        [self hideSpinnerWithName:@""];
        
        
        [[CommonManager shared] setupApiToken:_loginRequest.apiToken];
        [[CommonManager shared] setupUserId:[_loginRequest.user safeStringObjectForKey:@"id"]];
        
        
        NSString *apiToken = _loginRequest.apiToken;
        NSLog(@"login completed: %@", apiToken);
        
        if (_successBlock) {
            _successBlock(self, apiToken);
        }
        
    } failure:^(LoginRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"login failed: %@", error);
        NSLog(@"Response: %@", request.response);
        
        if (_successBlock) {
            _successBlock(self, nil);
        }

        
    }];
    
}


#pragma mark _______________________ Privat Methods(view)___________________
//! Update views by model
- (void)updateViews{

}

#pragma mark _______________________ Privat Methods ________________________


- (void)hideKeyBoard{
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (BOOL)isTextFieldsValid{
    
    if (![_emailTextField.text isValidateEmail]) {
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

- (void)loginWithFB{
    
    [[FacebookManager shared] loginWithReadPermissions:@[@"publish_stream",@"email"]
                                          allowLoginUI:YES
                                               success:^(FBSession *session, FBSessionState status) {
                                                   
                                                   NSLog(@"accessToken = %@", session.accessTokenData.accessToken);
                                                   
                                                   [self loadMeFB];
                                               }
                                               failure:^(FBSession *session, FBSessionState status, NSError *error) {
                                                   [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                       message:error.localizedDescription];
                                               }
                                         olreadyLogged:^(FBSession *session, FBSessionState status) {
                                             NSLog(@"accessToken = %@", session.accessTokenData.accessToken);
                                             [self loadMeFB];
                                         }];
}


- (void)loadMeFB{
    
    [self showSpinnerWithName:@""];
    [[FacebookManager shared] loadMeWithSuccess:^(id<FBGraphUser> user) {
        [self hideSpinnerWithName:@""];
        [self authWithFBUser:user];
    }
                                        failure:^(FBRequestConnection *connection, id result, NSError *error) {
                                            [self hideSpinnerWithName:@""];
                                            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                message:error.localizedDescription];
                                        }];
}

- (void)authWithFBUser:(id<FBGraphUser>)user{
    
    NSString* userName = user.name;
    NSString* user_id = user.objectID;
    NSString* email = [user objectForKey:@"email"];
    
    LoginViaSocialRequest* authRequest = [[LoginViaSocialRequest alloc] init];
    
    authRequest.userId = user_id;
    authRequest.username = userName;
    authRequest.email = email;
    authRequest.credentialToken = [FBSession activeSession].accessTokenData.accessToken;
    authRequest.type = @"facebook";
   
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:authRequest
                                            success:^(LoginViaSocialRequest *request) {
                                                [self hideSpinnerWithName:@""];
                                                NSLog(@"Registration complete! %@", request.response);
                                               
                                                [[CommonManager shared] setupUserId:[[request.user safeNumberObjectForKey:@"id"] stringValue]];
                                                [[CommonManager shared] setupApiToken:request.apiToken];
                                                
                                                NSLog(@"logged in");
                                                
                                                if (_successBlock) {
                                                    _successBlock(self, request.apiToken);
                                                }
                                                
                                            } failure:^(LoginViaSocialRequest *request, NSError *error) {
                                                [self hideSpinnerWithName:@""];
                                                NSLog(@"Registration failed: %@", error);
                                                NSLog(@"Response: %@", request.response);
                                                
                                                [self hideSpinnerWithName:@""];
                                                [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                    message:error.localizedDescription];

                                            }];
    
}


- (void)loginWithTwitter{
    
    
    [[TwitterManager shared] loginVCPresentation:^(UIViewController *twitterLoginVC) {
        [self presentViewController:twitterLoginVC animated:YES completion:^{}];
    }
                                         success:^(UIViewController *twitterLoginVC, FHSToken *token) {
                                             [self showEmailAlert];
                                         }
                                         failure:^(UIViewController *twitterLoginVC, NSError *error) {
                                             
                                             [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                 message:@"Login failed"];
                                         }
                                          cancel:^(UIViewController *twitterLoginVC) {
                                              
                                          }
                                 alreadyLoggedIn:^(UIViewController *twitterLoginVC, FHSToken *token) {
                                                                                  [self showEmailAlert];
                                 }];
    

}

- (void)authTwitterWithEmail:(NSString*)email{
    
      
    NSString* userName = [FHSTwitterEngine sharedEngine].authenticatedUsername;
    NSString* user_id = [FHSTwitterEngine sharedEngine].authenticatedID;
    NSString* tocken = [FHSTwitterEngine sharedEngine].accessToken.key;
    
    LoginViaSocialRequest* authRequest = [[LoginViaSocialRequest alloc] init];
    
    authRequest.userId = user_id;
    authRequest.username = userName;
    authRequest.email = email;
    authRequest.credentialToken = tocken;
    authRequest.type = @"twitter";
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:authRequest
                                            success:^(LoginViaSocialRequest *request) {
                                                [self hideSpinnerWithName:@""];
                                                NSLog(@"Registration complete! %@", request.response);
                                                
                                                [[CommonManager shared] setupUserId:[[request.user safeNumberObjectForKey:@"id"] stringValue]];
                                                [[CommonManager shared] setupApiToken:request.apiToken];
                                                
                                                NSLog(@"logged in");
                                                
                                                if (_successBlock) {
                                                    _successBlock(self, request.apiToken);
                                                }
                                                
                                            } failure:^(LoginViaSocialRequest *request, NSError *error) {
                                                [self hideSpinnerWithName:@""];
                                                NSLog(@"Registration failed: %@", error);
                                                NSLog(@"Response: %@", request.response);
                                                
                                                [self hideSpinnerWithName:@""];
                                                [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                    message:error.localizedDescription];
                                                
                                            }];
    
}

- (void)showEmailAlert {
    
   [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, UITextField *firstTextField, UITextField *secondTextField, NSInteger buttonIndex) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            
        }else{
            if ([firstTextField.text isValidateEmail]) {
                [self authTwitterWithEmail:firstTextField.text];
            }else{
                [self showEmailInvalidAlert];
            }
        }
    }
                                           title:@"Enter your account email"
                                         message:@"Email:"
                                firstPlaceholder:@"Enter email"
                               secondPlaceholder:nil
                                  alertViewStyle:UIAlertViewStylePlainTextInput
                               cancelButtonTitle:@"Cancel"
                               otherButtonTitles:@"Ok", nil];
    
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

#pragma mark _______________________ Buttons Action ________________________

- (IBAction)loginButtonClicked:(id)sender {
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    
    if ([self isTextFieldsValid]) {
        [self hideKeyBoard];
        [self loginWithEmail:_emailTextField.text pass:_passwordTextField.text];
    }
}

- (IBAction)forgotPasswordButtonClicked:(id)sender
{
    // push for forgot password from here
    
    ForgetPasswordVC * forgotVC = [ForgetPasswordVC loadFromXIBForScrrenSizes];
    [self.navigationController pushViewController:forgotVC animated:YES];
}
- (IBAction)facebookButtonClicked:(id)sender {
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self loginWithFB];
//    if (_successBlock) {
//        _successBlock(self, nil);
//    }
}

- (IBAction)twitterButtonClicked:(id)sender {
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self loginWithTwitter];
}

- (IBAction)forgotPassButtonClicked:(id)sender {
    [self forgotPasswordButtonClicked:nil];
}

- (IBAction)signUpButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark _______________________ Delegates _____________________________

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        [self.emailTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }else  {
        [self.passwordTextField resignFirstResponder];
    }
    
    return YES;
}


#pragma mark _______________________ Public Methods ________________________



#pragma mark _______________________ Notifications _________________________



@end
