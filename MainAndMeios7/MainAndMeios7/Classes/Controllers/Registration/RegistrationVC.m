//
//  RegistrationVC.m
//  MainAndMeios7
//
//  Created by Bhumi Shah on 03/11/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RegistrationVC.h"
#import "RegistrationCell.h"
@interface RegistrationVC ()

@property (weak, nonatomic)IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic)IBOutlet UIScrollView *scroll;
@property (weak, nonatomic)IBOutlet UITextField *txtFullName;
@property (weak, nonatomic)IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic)IBOutlet UITextField *txtPassword;
@property (weak, nonatomic)IBOutlet UITextField *txtConfirmPassword;
@property (weak, nonatomic)IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic)IBOutlet UIView *viewMain;


@end

@implementation RegistrationVC

#pragma mark _______________________ View Methods ________________________


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *attrDict = @{NSFontAttributeName : [UIFont
                                                      systemFontOfSize:12.0],NSForegroundColorAttributeName : [UIColor
                                                                                                                lightGrayColor]};
    NSMutableAttributedString *title =[[NSMutableAttributedString alloc] initWithString:@"Already a user? Login" attributes: attrDict];
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0,[title length])];
    [_btnSignIn setAttributedTitle:title forState:UIControlStateNormal];
    if([[CommonManager shared] isFourInchScreen])
    {
        _imgBackground.image = [UIImage imageNamed:@"signup_back"];
        CGRect rect  = _viewMain.frame;
        rect.origin.y = -60;
        _viewMain.frame = rect;
        
    }
   
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
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark _______________________ Class Methods _________________________


+ (void)registrationVCPresentation:(void (^)(RegistrationVC* registrationVC))presentation
                           success:(void (^)(RegistrationVC* registrationVC, NSString* token))success
                           failure:(void (^)(RegistrationVC* registrationVC, NSError* error))failure;
 {
    
    RegistrationVC* registrationVC = [RegistrationVC loadFromXIB_Or_iPhone5_XIB];
    registrationVC.successBlock = success;
    registrationVC.failureBlock = failure;

    presentation(registrationVC);
  
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 50) ? NO : YES;
    
    return YES;
}

#pragma mark _______________________ Button Click Methods ________________________

-(IBAction)btnSignUpClick:(id)sender
{
   
    _txtFullName.text=[_txtFullName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _txtEmailAddress.text=[_txtEmailAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _txtPassword.text=[_txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _txtConfirmPassword.text=[_txtConfirmPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(_txtFullName.text.length == 0)
    {
       
        NSLog(@"Please enter Full Name");
    }
    else if(_txtEmailAddress.text.length == 0)
    {

        NSLog(@"Please enter E-mail address");
    }
    else if(![_txtEmailAddress.text isValidateEmail])
    {
        
        NSLog(@"Please enter valid E-mail address");
    }
    else if(_txtPassword.text.length<8)
    {
        
        NSLog(@"Please enter atleast 8 characters Password");
    }
    else if(_txtConfirmPassword.text.length<8)
    {
       
        NSLog(@"Please enter atleast 8 characters Confirm Password");
    }
    else if([_txtPassword.text isEqualToString:_txtConfirmPassword.text])
    {
        
        NSLog(@"Password and Confirm Password do not match");
    }
    else
    {
        if (_successBlock) {
            _successBlock(self, nil);
        }
    }
    
    //Register
}

-(IBAction)btnAlreadyRegistered:(id)sender
{
    if (_failureBlock) {
        _failureBlock(self, nil);
    }
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

- (void) moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up
{
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
    float lastTextFldOrigin = _txtConfirmPassword.frame.origin.y+_txtConfirmPassword.frame.size.height+10;
    if([[CommonManager shared] isFourInchScreen])
    {
        lastTextFldOrigin += -60;
    }
    
    if(!up)
    {
         _scroll.contentOffset = CGPointMake(_scroll.contentOffset.x, 0);
    }
    else
    {
        if(lastTextFldOrigin>keyBoardOrigin)
        {
            _scroll.contentOffset = CGPointMake(_scroll.contentOffset.x, lastTextFldOrigin-keyBoardOrigin);
        }
    }
    
    
    [UIView commitAnimations];
}

@end
