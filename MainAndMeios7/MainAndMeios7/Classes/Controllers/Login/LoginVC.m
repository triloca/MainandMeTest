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
#import "RegistrationVC.h"

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
    
    LoginVC* loginVC = [LoginVC loadFromXIBForScrrenSizes];
    loginVC.successBlock = success;
    loginVC.failureBlock = failure;
    loginVC.alreadyLoggedInBlock = alreadyLoggedIn;
    
    if ([[CommonManager shared] loginMethod] == LoginMethodNone) {
        presentation(loginVC);
    }else{
        
        [loginVC loginWithLastMethod:[[CommonManager shared] loginMethod]
                             success:^{
                                 alreadyLoggedIn(loginVC, [[CommonManager shared] apiToken]);
                             }
                             failure:^(NSError *error) {
                                 presentation(loginVC);
                             }];
    }
    
    
    ////
//    if ([[CommonManager shared] isLoggedIn]) {
//        alreadyLoggedIn(loginVC, [[CommonManager shared] apiToken]);
//    }else{
//        presentation(loginVC);
//    }
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
        [[CommonManager shared] setupUserId:[[_loginRequest.user safeNumberObjectForKey:@"id"] stringValue]];
        
        NSString *apiToken = _loginRequest.apiToken;
        NSLog(@"login completed: %@", apiToken);
        
        if (_successBlock) {
            _successBlock(self, apiToken);
        }
        
    } failure:^(LoginRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"login failed: %@", error);
        NSLog(@"Response: %@", request.response);
        
        if ([request.response isKindOfClass:[NSDictionary class]]) {
            NSDictionary* response = (NSDictionary*)request.response;
            [[AlertManager shared] showOkAlertWithTitle:[response safeStringObjectForKey:@"message"]];
        }
        
        
        if (_failureBlock) {
            _failureBlock(self, error);
        }

        
    }];
    
}

- (void)authWithEmail:(NSString*)email
                  pass:(NSString*)pass
               success:(void(^)(LoginRequest* request, NSString* apiToken, NSDictionary *user))success
               failure:(void(^)(LoginRequest *request, NSError *error))failure{
    
    LoginRequest *loginRequest = [[LoginRequest alloc] init];
    loginRequest.email = email;
    loginRequest.password = pass;
    
    [[MMServiceProvider sharedProvider] sendRequest:loginRequest success:^(LoginRequest *_loginRequest) {
        
        NSString *apiToken = _loginRequest.apiToken;
        NSLog(@"login completed: %@", apiToken);
        
            success(_loginRequest, _loginRequest.apiToken, _loginRequest.user);
        
        
    } failure:^(LoginRequest *request, NSError *error) {
        NSLog(@"login failed: %@", error);
        NSLog(@"Response: %@", request.response);
        
        failure(request, error);
        
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
    
    [[FacebookManager shared] loginWithReadPermissions:nil//@[@"publish_stream",@"email"]
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
                                                
                                                //!
                                                [[CommonManager shared] setLoginMethod:LoginMethodFB];
                                                [[CommonManager shared] setupFbID:user_id];
                                                [[CommonManager shared] setupUserName:userName];
                                                [[CommonManager shared] setupEmail:email];
                                                [[CommonManager shared] setupCredentialToken:[FBSession activeSession].accessTokenData.accessToken];
                                                
                                                NSLog(@"logged in");
                                                
                                                if (_successBlock) {
                                                    _successBlock(self, request.apiToken);
                                                }
                                                
                                            } failure:^(LoginViaSocialRequest *request, NSError *error) {
                                                [self hideSpinnerWithName:@""];
                                                NSLog(@"Registration failed: %@", error);
                                                NSLog(@"Response: %@", request.response);
                                                
                                                [[CommonManager shared] logout];
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
                                                
                                                [[CommonManager shared] setLoginMethod:LoginMethodTwitter];
                                                [[CommonManager shared] setupEmail:email];
                                                [[CommonManager shared] setupUserName:userName];
                                                [[CommonManager shared] setupAuthenticatedID:user_id];
                                                [[CommonManager shared] setupCredentialToken:tocken];
                                                
                                                
                                                if (_successBlock) {
                                                    _successBlock(self, request.apiToken);
                                                }
                                                
                                            } failure:^(LoginViaSocialRequest *request, NSError *error) {
                                                [self hideSpinnerWithName:@""];
                                                NSLog(@"Registration failed: %@", error);
                                                NSLog(@"Response: %@", request.response);
                                                [[CommonManager shared] logout];
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


- (void)loginWithLastMethod:(LoginMethod)method
                    success:(void(^)())success
                    failure:(void(^)(NSError *error))failure{

    if (method == LoginMethodEmail) {
        
        [self authWithEmail:[CommonManager shared].email
                       pass:[CommonManager shared].pass
                    success:^(LoginRequest *request, NSString *apiToken, NSDictionary *user) {
                        
                        
                        [[CommonManager shared] setupApiToken:apiToken];
                        [[CommonManager shared] setupUserId:[[user safeNumberObjectForKey:@"id"] stringValue]];
                        
                        NSLog(@"login completed: %@", apiToken);
                        success();
                    }
                    failure:^(LoginRequest *request, NSError *error) {
                        failure(error);
                    }];
        
    }else if (method == LoginMethodFB){
    
        LoginViaSocialRequest* authRequest = [[LoginViaSocialRequest alloc] init];
        
        authRequest.userId = [[CommonManager shared] fbID];
        authRequest.username = [[CommonManager shared] userName];
        authRequest.email = [[CommonManager shared] email];
        authRequest.credentialToken = [[CommonManager shared] credentialToken];
        authRequest.type = @"facebook";
        
        [[MMServiceProvider sharedProvider] sendRequest:authRequest
                                                success:^(LoginViaSocialRequest *request) {
                                                    NSLog(@"Registration complete! %@", request.response);
                                                    
                                                    [[CommonManager shared] setupUserId:[[request.user safeNumberObjectForKey:@"id"] stringValue]];
                                                    [[CommonManager shared] setupApiToken:request.apiToken];
                                                    
                                                    NSLog(@"logged in");
                                                    
                                                    success();
                                                    
                                                } failure:^(LoginViaSocialRequest *request, NSError *error) {
                                                    NSLog(@"Registration failed: %@", error);
                                                    NSLog(@"Response: %@", request.response);
                                                    
                                                    [[CommonManager shared] logout];
                                                    
                                                    [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                        message:error.localizedDescription];
                                                    
                                                    failure(error);
                                                    
                                                }];

        
    }else if (method == LoginMethodTwitter){
        
        NSString* userName = [[CommonManager shared] userName];//[FHSTwitterEngine sharedEngine].authenticatedUsername;
        NSString* user_id = [[CommonManager shared] authenticatedID];//[FHSTwitterEngine sharedEngine].authenticatedID;
        NSString* tocken = [[CommonManager shared] credentialToken];//[FHSTwitterEngine sharedEngine].accessToken.key;
        
        LoginViaSocialRequest* authRequest = [[LoginViaSocialRequest alloc] init];
        
        authRequest.userId = user_id;
        authRequest.username = userName;
        authRequest.credentialToken = tocken;
       
        authRequest.email = [[CommonManager shared] email];

        authRequest.type = @"twitter";
        
        [self showSpinnerWithName:@""];
        [[MMServiceProvider sharedProvider] sendRequest:authRequest
                                                success:^(LoginViaSocialRequest *request) {
                                                    [self hideSpinnerWithName:@""];
                                                    NSLog(@"Registration complete! %@", request.response);
                                                    
                                                    [[CommonManager shared] setupUserId:[[request.user safeNumberObjectForKey:@"id"] stringValue]];
                                                    [[CommonManager shared] setupApiToken:request.apiToken];
                                                    
                                                    NSLog(@"logged in");
                                                    
                                                    success();
                                                    
                                                } failure:^(LoginViaSocialRequest *request, NSError *error) {
                                                    [self hideSpinnerWithName:@""];
                                                    NSLog(@"Registration failed: %@", error);
                                                    NSLog(@"Response: %@", request.response);
                                                    
                                                    [self hideSpinnerWithName:@""];
                                                    [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                        message:error.localizedDescription];
                                                    failure(error);
                                                }];

        
    }
}

#pragma mark _______________________ Buttons Action ________________________

- (IBAction)loginButtonClicked:(id)sender {
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    
    if ([self isTextFieldsValid]) {
        [self hideKeyBoard];
        
        [self authWithEmail:_emailTextField.text
                       pass:_passwordTextField.text
                    success:^(LoginRequest *request, NSString *apiToken, NSDictionary *user) {
                        
                        [[CommonManager shared] setupApiToken:apiToken];
                        [[CommonManager shared] setupUserId:[[user safeNumberObjectForKey:@"id"] stringValue]];
                        [[CommonManager shared] setLoginMethod:LoginMethodEmail];
                        NSLog(@"login completed: %@", apiToken);
                        
                        [[CommonManager shared] setupEmail:_emailTextField.text];
                        [[CommonManager shared] setupPass:_passwordTextField.text];

                        
                        if (_successBlock) {
                            _successBlock(self, apiToken);
                        }

                    }
                    failure:^(LoginRequest *request, NSError *error) {
                       
                        NSLog(@"login failed: %@", error);
                        NSLog(@"Response: %@", request.response);
                        
                        if ([request.response isKindOfClass:[NSDictionary class]]) {
                            NSDictionary* response = (NSDictionary*)request.response;
                            [[AlertManager shared] showOkAlertWithTitle:[response safeStringObjectForKey:@"message"]];
                        }
                        
                        [[CommonManager shared] logout];
                        
                        if (_failureBlock) {
                            _failureBlock(self, error);
                        }
                        
                    }];
        
        //[self loginWithEmail:_emailTextField.text pass:_passwordTextField.text];
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
    
    
    [self showRegistratioVC];
    
    //[self.navigationController popViewControllerAnimated:YES];
}


- (void)showRegistratioVC{
    
    [RegistrationVC registrationVCPresentation:^(UIViewController *registrationVC) {
        
//        UINavigationController* registrationNVC = [[UINavigationController alloc] initWithRootViewController:registrationVC];
        
        [registrationVC view];
        
//        [[LayoutManager shared].rootNVC presentViewController:registrationNVC
//                                                     animated:NO
//                                                   completion:^{}];
        
        [self.navigationController pushViewController:registrationVC
                                             animated:YES];
        
    } success:^(UIViewController *registrationVC, NSString *token, NSDictionary* user) {
        
        
        if (_successBlock) {
            _successBlock(self, token);
        }

//        [[LayoutManager shared] profileNVC];
//        [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
//        [[LayoutManager shared].profileVC view];
//        
//        [[LayoutManager shared].homeVC didLoginSuccessfuly];
//        
//        [registrationVC.navigationController dismissViewControllerAnimated:YES completion:^{}];
        
    } failure:^(UIViewController *registrationVC, NSError *error) {
        if (_failureBlock) {
            _failureBlock(self, error);
        }
    }];
    
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
