//
//  LoginVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/1/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoginVC.h"
#import "RegistrationVC.h"
#import "LoginRequest.h"
#import "NSString+Email.h"

@interface LoginVC()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@end


@implementation LoginVC

#pragma mark _______________________ Class Methods _________________________




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

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark _______________________ Privat Methods(view)___________________
//! Update views by model
- (void)updateViews{

}

#pragma mark _______________________ Privat Methods ________________________

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
    }];
    
}

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


#pragma mark _______________________ Buttons Action ________________________

- (IBAction)loginButtonClicked:(id)sender {
    if ([self isTextFieldsValid]) {
        [self hideKeyBoard];
        [self loginWithEmail:_emailTextField.text pass:_passwordTextField.text];
    }
}
- (IBAction)facebookButtonClicked:(id)sender {
    if (_successBlock) {
        _successBlock(self, nil);
    }
}

- (IBAction)twitterButtonClicked:(id)sender {
    if (_successBlock) {
        _successBlock(self, nil);
    }
}

#pragma mark _______________________ Delegates _____________________________



#pragma mark _______________________ Public Methods ________________________



#pragma mark _______________________ Notifications _________________________



@end
