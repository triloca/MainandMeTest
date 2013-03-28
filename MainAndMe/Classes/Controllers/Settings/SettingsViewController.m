//
//  ProductDetailViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "SettingsViewController.h"
#import "UIView+Common.h"
#import "DataManager.h"
#import "PhoneNumberFormatter.h"
#import "SettingsManager.h"
#import "AlertManager.h"
#import "AppDelegate.h"
#import "ReachabilityManager.h"
#import "InviteFriendViewController.h"
#import "ProfileViewController.h"


@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UIImageView *personImageView;
@property (weak, nonatomic) IBOutlet UISwitch *communitiesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *storeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *peopleSwitch;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendsButton;
@property (weak, nonatomic) IBOutlet UISwitch *makePrivateSwitch;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIDatePicker *birthdayPicker;
@property (assign, nonatomic) BOOL isPickerVisible;

@property (assign, nonatomic) BOOL isKeyBoardVisible;
@property (assign, nonatomic) BOOL phoneFormatterFlag;
@property (strong, nonatomic) PhoneNumberFormatter* phoneNumberFormatter;

@end

@implementation SettingsViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Settings";
    
    CGRect rc  = _scrollView.frame;
    _scrollView.contentSize = rc.size;
    
        
    [self.view addSubview:_scrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];



    _phoneNumberFormatter = [PhoneNumberFormatter new];
    [self updateViews];
    //[self loadProfileInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(IS_IPHONE_5){
        _scrollView.frame = CGRectMake(0, 42, 320, 465);
    }else{
        _scrollView.frame = CGRectMake(0, 42, 320, 385);
    }

}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTitleTextLabel:nil];
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setBirthdayTextField:nil];
    [self setPhoneNumberTextField:nil];
    [self setAddressTextView:nil];
    [self setPersonImageView:nil];
    [self setCommunitiesSwitch:nil];
    [self setStoreSwitch:nil];
    [self setPeopleSwitch:nil];
    [self setInviteFriendsButton:nil];
    [self setMakePrivateSwitch:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self hideKeyboard];
    [self hidePicker];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveDetailsButtonClicked:(id)sender {
    [self hideKeyboard];
    [self hidePicker];
    [self updateUserInfo];
}

- (IBAction)inviteFriendsButtonClicked:(id)sender {
    InviteFriendViewController* inviteFriendViewController = [InviteFriendViewController new];
    [self.navigationController pushViewController:inviteFriendViewController animated:YES];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self hidePicker];
    [self scrollToTextField:textField];
    if (textField == _birthdayTextField) {
        [self hideKeyboard];
        [self showPicker];
        return NO;
    }
    

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

#pragma mark - TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    //_isKeyBoardVisible = YES;
    [self hidePicker];
    [_scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - 100) animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
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
    //CGFloat height = self.view.frame.size.height;
    if (_isKeyBoardVisible || _isPickerVisible) {
        [_scrollView setContentSize:CGSizeMake(0, 607 + 220)];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            [_scrollView setContentSize:CGSizeMake(0, 607)];
            [_scrollView setContentOffset:CGPointMake(0, 0)];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)scrollToTextField:(UITextField*)textField {
    if (textField == _usernameTextField) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        [_scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 100) animated:YES];
    }
}

- (void)jampToNextTextField:(UITextField*)textField{
    if (textField == _usernameTextField) {
        
        [_passwordTextField becomeFirstResponder];
    }else if (textField == _passwordTextField) {
        
        [_birthdayTextField becomeFirstResponder];
    }else if (textField == _birthdayTextField) {
        
        [_phoneNumberTextField becomeFirstResponder];
    }else if (textField == _phoneNumberTextField) {
        
        [_addressTextView becomeFirstResponder];
    }
}


- (void)hideKeyboard{
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_birthdayTextField resignFirstResponder];
    [_phoneNumberTextField resignFirstResponder];
    [_addressTextView resignFirstResponder];
}


- (void)updateViews{
    _usernameTextField.text = [_profileInfo safeStringObjectForKey:@"name"];
    _passwordTextField.text = @"";
    [self setPersonImageURLString:[_profileInfo safeStringObjectForKey:@"avatar_url"]];
    
//    NSDate* date = [DataManager dateFromString:[_profileInfo safeStringObjectForKey:@"date_of_birth"]];
    _birthdayTextField.text = [_profileInfo safeStringObjectForKey:@"date_of_birth"];
    _phoneNumberTextField.text = [_profileInfo safeStringObjectForKey:@"phone_number"];

    _addressTextView.text = [_profileInfo safeStringObjectForKey:@"address"];
    [_communitiesSwitch setOn:[[_profileInfo safeNumberObjectForKey:@"email_communities"] boolValue]
                     animated:NO];
    [_storeSwitch setOn:[[_profileInfo safeNumberObjectForKey:@"email_stores"] boolValue]
               animated:NO];
    [_peopleSwitch setOn:[[_profileInfo safeNumberObjectForKey:@"email_people"] boolValue]
                animated:NO];
    
//    id obj = [_profileInfo objectForKey:@"wishlist"];
//    BOOL test = [[_profileInfo safeNumberObjectForKey:@"wishlist"] boolValue];
    [_makePrivateSwitch setOn:[[_profileInfo safeStringObjectForKey:@"wishlist"] boolValue]
                     animated:NO]; 
}

- (void)setPersonImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.personImageView  setImageWithURLRequest:request
                                 placeholderImage:[UIImage imageNamed:@"posted_user_ic@2x.png"]
                                     failureImage:nil
                                 progressViewSize:CGSizeMake(_personImageView.bounds.size.width - 5, 4)
                                progressViewStile:UIProgressViewStyleDefault
                                progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                                   trackTintColor:nil
                                       sizePolicy:UNImageSizePolicyScaleAspectFill
                                      cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                          success:nil
                                          failure:nil
                                         progress:nil];
    
}

- (IBAction)phoneNumberDidChanged:(UITextField*)sender {
    if (_phoneFormatterFlag) {
        return;
    }
    _phoneFormatterFlag = 1;
    
    sender.text = [_phoneNumberFormatter format:sender.text withLocale:@"us"];
    
    _phoneFormatterFlag = 0;

}

- (void)showPicker{
    
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _isPickerVisible = YES;
    [self updateContentSize];
    
    if (_birthdayPicker == nil) {
        self.birthdayPicker = [[UIDatePicker alloc] init];
        CGRect rc = _birthdayPicker.frame;
        rc.origin.y = self.view.size.height;
        _birthdayPicker.frame = rc;
        
        _birthdayPicker.datePickerMode = UIDatePickerModeDate;
        _birthdayPicker.locale = [NSLocale currentLocale];
        _birthdayPicker.maximumDate = [NSDate date];
        
        [_birthdayPicker addTarget:self
                            action:@selector(pickerChanged:)
                  forControlEvents:UIControlEventValueChanged];
        
        [delegate.window addSubview:_birthdayPicker];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rc = _birthdayPicker.frame;
        rc.origin.y = delegate.window.size.height - rc.size.height;
        _birthdayPicker.frame = rc;
    } completion:^(BOOL finished) {
        
    }];
    
}


- (void)hidePicker{
    
    //    if (_isPickerVisible) {
    //        [self validateBirthday];
    //    }
    
    _isPickerVisible = NO;
    [self updateContentSize];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rc = _birthdayPicker.frame;
        rc.origin.y = 568;
        _birthdayPicker.frame = rc;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)pickerChanged:(UIDatePicker*)sender{
    _birthdayTextField.text = [DataManager birthdayFromDate:sender.date];
}

- (void)loadProfileInfo{
   
    [self showSpinnerWithName:@"ProfileViewController"];
    [SettingsManager loadCurrentUserWithSuccess:^(NSDictionary *profile) {
        [self hideSpinnerWithName:@"ProfileViewController"];
        _profileInfo = profile;
        [self updateViews];
    }
                                        failure:^(NSError *error, NSString *errorString) {
                                            [self hideSpinnerWithName:@"ProfileViewController"];
                                            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                message:errorString];

                                        }
                                      exception:^(NSString *exceptionString) {
                                          [self hideSpinnerWithName:@"ProfileViewController"];
                                          [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                      }];
    
}


- (void)updateUserInfo{
    [self showSpinnerWithName:@"ProfileViewController"];
    [SettingsManager saveCurrentUserWithName:_usernameTextField.text
                                    password:_passwordTextField.text
                                    birthday:_birthdayTextField.text
                                     address:_addressTextView.text
                                phone_number:_phoneNumberTextField.text
                           email_communities:_communitiesSwitch.isOn
                                email_stores:_storeSwitch.isOn
                                email_people:_peopleSwitch.isOn
                                    wishlist:_makePrivateSwitch.isOn
                                     success:^(NSDictionary *profile) {
                                         [self hideSpinnerWithName:@"ProfileViewController"];
                                         _profileInfo = profile;
                                         [self updateViews];
                                         [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                                                             message:@"Details Saved."];
                                         NSArray* controllers = self.navigationController.viewControllers;
                                         id obj = [controllers safeObjectAtIndex:[controllers count] - 2];
                                         if ([obj isKindOfClass:[ProfileViewController class]]) {
                                             ProfileViewController* controller = (ProfileViewController*)obj;
                                             controller.isNeedUpdate = YES;
                                         }
                                     }
                                     failure:^(NSError *error, NSString *errorString) {
                                         [self hideSpinnerWithName:@"ProfileViewController"];
                                         [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                             message:errorString];

                                     }
                                   exception:^(NSString *exceptionString) {
                                       [self hideSpinnerWithName:@"ProfileViewController"];
                                       [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                   }];
}
@end
