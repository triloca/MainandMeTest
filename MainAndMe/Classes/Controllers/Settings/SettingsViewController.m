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

@property (assign, nonatomic) BOOL isKeyBoardVisible;

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



    [self updateViews];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveDetailsButtonClicked:(id)sender {
    
}

- (IBAction)inviteFriendsButtonClicked:(id)sender {
    
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
    CGFloat height = _scrollView.contentSize.height;
    if (_isKeyBoardVisible) {
        [_scrollView setContentSize:CGSizeMake(0, height + 216)];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            [_scrollView setContentSize:CGSizeMake(0, height - 216)];
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
    _passwordTextField.text = @"zzzzzz";
    [self setPersonImageURLString:[_profileInfo safeStringObjectForKey:@"avatar_url"]];
    
    NSDate* date = [DataManager dateFromString:[_profileInfo safeStringObjectForKey:@"date_of_birth"]];
    
//    _agoLabel.text = [DataManager howLongAgo:date];
//    
//    address city
//    created_at
//    
//    email
//    first_name
//    last_name
//    name
//    permissions =     {
//        create = 1;
//        destroy = 1;
//        manage = 1;
//        read = 1;
//        update = 1;
//    };
//    phone_number
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

@end
