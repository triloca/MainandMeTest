//
//  SignUpViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//
//

#import "SignUpViewController.h"
#import "NSString+Common.h"
#import "AlertManager.h"
#import "LoginSignUpManager.h"
#import "MBProgressHUD.h"

@interface SignUpViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) BOOL isKeyBoardVisible;

@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation SignUpViewController

#pragma mark - Init
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

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.emailTextField = nil;
    self.passwordTextField = nil;
    self.confirmPasswordTextField = nil;
    self.userNameTextField = nil;
    self.scrollView = nil;
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
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)scrollToTextField:(UITextField*)textField {
    if (textField == _emailTextField) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        [_scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 100) animated:YES];
    }
}

- (void)jampToNextTextField:(UITextField*)textField{
    if (textField == _emailTextField) {
        
        [_passwordTextField becomeFirstResponder];
    }else if (textField == _passwordTextField) {
        
        [_confirmPasswordTextField becomeFirstResponder];
    }else if (textField == _confirmPasswordTextField) {
        
        [_userNameTextField becomeFirstResponder];
    }else if (textField == _userNameTextField) {
        
        [_userNameTextField resignFirstResponder];
    }
}


- (void)hideKeyboard{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_confirmPasswordTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
}

- (BOOL)validateTextFields{
    
    if (![_emailTextField.text isValidEmail]) {
        [self showAlertWithText:@"Enter valid Email"];
        [_emailTextField becomeFirstResponder];
        return NO;
    }
    if (_passwordTextField.text.length == 0) {
        [self showAlertWithText:@"Enter Password"];
        [_passwordTextField becomeFirstResponder];
        return NO;
    }
    if (_passwordTextField.text.length < 6) {
        [_passwordTextField becomeFirstResponder];
        [self showAlertWithText:@"The password must be at least 6 characters long"];
        return NO;
    }
    if (_confirmPasswordTextField.text.length == 0) {
        [_confirmPasswordTextField becomeFirstResponder];
        [self showAlertWithText:@"Enter Confirm Password"];
        return NO;
    }
    if (![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
        [_passwordTextField becomeFirstResponder];
        [self showAlertWithText:@"Password and Confirm Password must be equal"];
        return NO;
    }
    if (_userNameTextField.text.length == 0) {
        [_userNameTextField becomeFirstResponder];
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
    _emailTextField.text = @"";
    _passwordTextField.text = @"";
    _confirmPasswordTextField.text = @"";
    _userNameTextField.text = @"";
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self scrollToTextField:textField];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    _isKeyBoardVisible = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[textField resignFirstResponder];
    [self jampToNextTextField:textField];
    return YES;
}


#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self hideKeyboard];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)signUpButtonClicked:(id)sender {
    if ([self validateTextFields]) {
        [self hideKeyboard];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [LoginSignUpManager signUpWithEmail:_emailTextField.text
                                   password:_passwordTextField.text
                                   userName:_userNameTextField.text
                                    success:^(NSString *token, NSString *email) {
                                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                        [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                                                            message:@"You successfully signed up to use Main And Me"];
                                        [self clearAllTextFields];
                                        [self.navigationController popViewControllerAnimated:YES];
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
}

@end
