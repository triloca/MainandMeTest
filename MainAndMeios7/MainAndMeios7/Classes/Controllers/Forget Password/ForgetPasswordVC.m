//
//  ForgetPasswordVC.m
//  MainAndMeios7
//
//  Created by apple n berry on 12/11/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ForgetPasswordVC.h"
#import "ForgotPasswordRequest.h"


@interface ForgetPasswordVC ()
@property (weak, nonatomic)IBOutlet UIScrollView *scroll;
@property (weak, nonatomic)IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic)IBOutlet UIButton *btnForgotPassword;
@property (weak, nonatomic)IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@end

@implementation ForgetPasswordVC

- (void)viewDidLoad
{
    [super viewDidLoad];
   
}
#pragma mark _______________________ View Lifecycle ________________________
- (BOOL)prefersStatusBarHidden
{
    return NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBarHidden = TRUE;
    
    NSDictionary *attrDict = @{NSFontAttributeName : _btnSignIn.titleLabel.font ,NSForegroundColorAttributeName : [UIColor
                                                                                                                   lightGrayColor]};
    
    NSMutableAttributedString *title =[[NSMutableAttributedString alloc] initWithString:@"Already a user? Login" attributes: attrDict];
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0,[title length])];
    [_btnSignIn setAttributedTitle:title forState:UIControlStateNormal];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self hideKeyboard];
    [self clearAllTextFields];
}


#pragma mark _______________________ Privat Methods ________________________

- (void)hideKeyboard{
  
    [_txtEmailAddress resignFirstResponder];
    
}

- (BOOL)validateTextFields{
    
    if (![_txtEmailAddress.text isValidateEmail])
    {
        [self showAlertWithText:@"Enter valid Email"];
        [_txtEmailAddress becomeFirstResponder];
        return NO;
    }
    
    return YES;
}


- (void)showAlertWithText:(NSString*)text
{
    
    [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                        message:text];
}

- (void)clearAllTextFields{
    
  
    _txtEmailAddress.text = @"";
    
}
-(void)forgotPasswordAction
{
    NSLog(@"forgotPasswordAction");
    
    ForgotPasswordRequest *forgotPswdRequest = [[ForgotPasswordRequest alloc] init];
    forgotPswdRequest.email = _txtEmailAddress.text;

    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }

    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:forgotPswdRequest success:^(ForgotPasswordRequest *request) {
        NSLog(@"Password recovery email sent");
        [self hideSpinnerWithName:@""];

        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
                                               title:@"Password was reset successfully"
                                             message:@"Please check your Email"
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];
        
        
    } failure:^(ForgotPasswordRequest *request, NSError* error) {
        NSLog(@"Password recovery failed with error: %@", error);
        [self hideSpinnerWithName:@""];
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
    }];


}
#pragma mark _______________________ Button Click Methods ________________________

-(IBAction)btnResetPasswordClick:(id)sender
{
    
   
    _txtEmailAddress.text=[_txtEmailAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  
    
    if ([self validateTextFields])
    {
        [self hideKeyboard];
        [self forgotPasswordAction];
    }
  
}

-(IBAction)btnAlreadyRegistered:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if(_txtEmailAddress == textField)
    {
        [textField resignFirstResponder];
        _scroll.contentOffset = CGPointMake(_scroll.contentOffset.x, 0);
    }
    
    return YES;
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
    
    float lastTextFldOrigin = _btnForgotPassword.frame.origin.y;
    
    CGFloat offset = 0;
    if (IS_IPHONE_4_OR_LESS) {
        offset = 80;
    }
    
    if (IS_IPHONE_5) {
        offset = 80;
    }
    
    if (IS_IPHONE_6) {
        offset = 40;
    }
    if (IS_IPHONE_6P) {
        offset = 10;
    }
    
    if(!up)
    {
        _scroll.contentOffset = CGPointMake(_scroll.contentOffset.x, 0);
    }
    else
    {
        float value = lastTextFldOrigin - keyBoardOrigin;
        if(value<0)
        {
            _scroll.contentOffset = CGPointMake(_scroll.contentOffset.x, offset);
        }
        else
        {
            _scroll.contentOffset = CGPointMake(_scroll.contentOffset.x, (lastTextFldOrigin -keyBoardOrigin)+ offset);
        }
        
        
    }
    
    
    [UIView commitAnimations];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
