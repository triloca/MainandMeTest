//
//  LoginViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//
//

#import "LoginViewController.h"
#import "SignUpViewController.h"

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
}
- (IBAction)facebookButtonClicked:(id)sender {
}
- (IBAction)twitterButtonClicked:(id)sender {
}
- (IBAction)createAccountButtonClicked:(id)sender {
    
    [self hideKeyBoard];
    
    SignUpViewController* signUpViewController = [SignUpViewController loadFromXIB_Or_iPhone5_XIB];
    [self.navigationController pushViewController:signUpViewController animated:YES];
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
@end
