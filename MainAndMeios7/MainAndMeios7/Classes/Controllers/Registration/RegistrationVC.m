//
//  RegistrationVC.m
//  MainAndMeios7
//
//  Created by Bhumi Shah on 03/11/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RegistrationVC.h"
#import "RegistrationCell.h"
#import "NSString+Email.h"
#import "RegistrationRequest.h"
#import "AddDeviceTokenRequest.h"
#import "LoginRequest.h"

@interface RegistrationVC ()

@property (weak, nonatomic)IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic)IBOutlet UIScrollView *scroll;
@property (weak, nonatomic)IBOutlet UITextField *txtFullName;
@property (weak, nonatomic)IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic)IBOutlet UITextField *txtPassword;
@property (weak, nonatomic)IBOutlet UITextField *txtConfirmPassword;
@property (weak, nonatomic)IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic)IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@property (weak, nonatomic) IBOutlet UIImageView *userLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *keyImageView;
@property (weak, nonatomic) IBOutlet UIImageView *signupBackImageView;

@end

@implementation RegistrationVC

#pragma mark _______________________ View Methods ________________________


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *attrDict = @{NSFontAttributeName : _btnSignIn.titleLabel.font ,NSForegroundColorAttributeName : [UIColor
                                                                                                                lightGrayColor]};
   
    NSMutableAttributedString *title =[[NSMutableAttributedString alloc] initWithString:@"Already a user? Login" attributes: attrDict];
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0,[title length])];
    [_btnSignIn setAttributedTitle:title forState:UIControlStateNormal];
    
//    if([[CommonManager shared] isFourInchScreen])
//    {
//        _imgBackground.image = [UIImage imageNamed:@"signup_back"];
//        CGRect rect  = _viewMain.frame;
//        rect.origin.y = -60;
//        _viewMain.frame = rect;
//        
//    }
   
    // Do any additional setup after loading the view from its nib.
    
    
}
#pragma mark _______________________ View Lifecycle ________________________

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBarHidden = TRUE;
   

    
}
- (void)viewWillDisappear:(BOOL)animated
{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self hideKeyboard];
    [self clearAllTextFields];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark _______________________ Class Methods _________________________


+ (void)registrationVCPresentation:(void (^)(UIViewController* registrationVC))presentation
                           success:(void (^)(UIViewController* registrationVC, NSString* token))success
                           failure:(void (^)(UIViewController* registrationVC, NSError* error))failure;
 {
    
    RegistrationVC* registrationVC = [RegistrationVC loadFromXIBForScrrenSizes];
    registrationVC.successBlock = success;
    registrationVC.failureBlock = failure;

    presentation(registrationVC);
  
}



#pragma mark _______________________ Privat Methods ________________________

- (void)hideKeyboard{
    [_txtFullName resignFirstResponder];
    [_txtPassword resignFirstResponder];
    [_txtEmailAddress resignFirstResponder];
    [_txtConfirmPassword resignFirstResponder];
}

- (BOOL)validateTextFields{
    
    if (![_txtEmailAddress.text isValidateEmail]) {
        [self showAlertWithText:@"Enter valid Email"];
        [_txtEmailAddress becomeFirstResponder];
        return NO;
    }
    if (_txtPassword.text.length == 0) {
        [self showAlertWithText:@"Enter Password"];
        [_txtPassword becomeFirstResponder];
        return NO;
    }
    if (_txtPassword.text.length < 6) {
        [_txtPassword becomeFirstResponder];
        [self showAlertWithText:@"The password must be at least 6 characters long"];
        return NO;
    }
    if (_txtConfirmPassword.text.length == 0) {
        [_txtConfirmPassword becomeFirstResponder];
        [self showAlertWithText:@"Enter Confirm Password"];
        return NO;
    }
    if (![_txtPassword.text isEqualToString:_txtConfirmPassword.text]) {
        [_txtPassword becomeFirstResponder];
        [self showAlertWithText:@"Password and Confirm Password must be equal"];
        return NO;
    }
    if (_txtFullName.text.length == 0) {
        [_txtFullName becomeFirstResponder];
        [self showAlertWithText:@"Enter Full Name"];
        return NO;
    }
    return YES;
}


- (void)showAlertWithText:(NSString*)text{
    
    [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                        message:text];
}

- (void)clearAllTextFields{
    
    _txtFullName.text = @"";
    _txtPassword.text = @"";
    _txtEmailAddress.text = @"";
    _txtConfirmPassword.text = @"";
}

- (void)registrationAction{

    
    RegistrationRequest *request = [[RegistrationRequest alloc] init];
    request.username = _txtFullName.text;
    request.password = _txtPassword.text;
    request.email = _txtEmailAddress.text;

    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(RegistrationRequest *request) {
        [self hideSpinnerWithName:@""];
        [[CommonManager shared] setupApiToken:request.api_token];
        
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self loginWithEmail:request.email pass:request.password];
        }
                                               title:@"Success"
                                             message:@"You successfully signed up to use Main And Me"
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        
        [self clearAllTextFields];

        
        NSLog(@"Registration complete! %@", request.response);
    } failure:^(RegistrationRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Registration failed: %@", error);
        NSLog(@"Response: %@", request.response);
    }];

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
    }];

}

#pragma mark _______________________ Text Field Delegate Methods ________________________

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
   
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(_txtFullName == textField)
    {
        [_txtEmailAddress becomeFirstResponder];
    }
    else if(_txtEmailAddress == textField)
    {
        [_txtPassword becomeFirstResponder];
    }
    else if(_txtPassword == textField)
    {
        [_txtConfirmPassword becomeFirstResponder];
    }
    else if(_txtConfirmPassword == textField)
    {
        [textField resignFirstResponder];
        _scroll.contentOffset = CGPointMake(_scroll.contentOffset.x, 0);
    }
   
    return YES;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
//    return (newLength > 50) ? NO : YES;
//    
//    return YES;
//}

#pragma mark _______________________ Button Click Methods ________________________

-(IBAction)btnSignUpClick:(id)sender
{
   
    _txtFullName.text=[_txtFullName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _txtEmailAddress.text=[_txtEmailAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _txtPassword.text=[_txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _txtConfirmPassword.text=[_txtConfirmPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([self validateTextFields]){
        [self hideKeyboard];
        [self registrationAction];
    }
    //Register
}

-(IBAction)btnAlreadyRegistered:(id)sender
{
    
    LoginVC* loginVC = [LoginVC loadFromXIBForScrrenSizes];
    
    loginVC.successBlock = _successBlock;
    loginVC.failureBlock = _failureBlock;
    loginVC.alreadyLoggedInBlock = _alreadyLoggedInBlock;
  
    [self.navigationController pushViewController:loginVC animated:YES];
}


#pragma mark _______________________ Keyboard hide and show notification  ________________________
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:NO];
}
#pragma mark _______________________ Move Scroll View on Text Feild ________________________

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up
{
//    if (up) {
//        _scroll.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
//    }else{
//        _scroll.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
//    }
    
    NSDictionary* userInfo = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
  
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    float keyBoardOrigin = keyboardFrame.origin.y;
    
    float lastTextFldOrigin = _signupButton.frame.origin.y;
   
    CGFloat offset = 0;
    if (IS_IPHONE_4_OR_LESS) {
        offset = 50;
    }
    
    if (IS_IPHONE_5) {
        offset = 100;
    }
    
    if (IS_IPHONE_6) {
        offset = 150;
    }
    if (IS_IPHONE_6P) {
        offset = 105;
    }
    
    if(!up)
    {
         _scroll.contentOffset = CGPointMake(_scroll.contentOffset.x, 0);
    }
    else
    {
       
            _scroll.contentOffset = CGPointMake(_scroll.contentOffset.x, (lastTextFldOrigin -keyBoardOrigin) + offset);
       
    }
    
    
    [UIView commitAnimations];
}

@end
