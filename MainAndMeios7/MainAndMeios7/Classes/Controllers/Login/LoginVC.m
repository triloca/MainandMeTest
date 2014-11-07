//
//  LoginVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/1/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoginVC.h"
#import "RegistrationVC.h"
@interface LoginVC()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
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

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark _______________________ Privat Methods(view)___________________
//! Update views by model
- (void)updateViews{

}

#pragma mark _______________________ Privat Methods ________________________



#pragma mark _______________________ Buttons Action ________________________

- (IBAction)loginButtonClicked:(id)sender {
    if (_successBlock) {
        _successBlock(self, nil);
    }
}
-(IBAction)registrationButtonClicked:(id)sender
{
    [RegistrationVC registrationVCPresentation:^(RegistrationVC *registrationVC) {
        UINavigationController* registrationNVC = [[UINavigationController alloc] initWithRootViewController:registrationVC];
        
        [registrationNVC view];
        
        [self.navigationController presentViewController:registrationNVC
                                                animated:NO
                                              completion:^{}];
        
    }
                                       success:^(RegistrationVC *registrationVC, NSString *token) {
                                           [registrationVC.navigationController dismissViewControllerAnimated:NO
                                                                                                   completion:^{}];
                                           if (_successBlock) {
                                               _successBlock(self, nil);
                                           }
                                       }
                                       failure:^(RegistrationVC *registrationVC, NSError *error) {
                                           [registrationVC.navigationController dismissViewControllerAnimated:YES
                                                                                                   completion:^{}];
                                           
                                       }
     ];
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
