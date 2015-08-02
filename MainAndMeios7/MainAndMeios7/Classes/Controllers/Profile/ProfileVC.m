//
//  ProfileVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 14.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ProfileVC.h"
#import "CustomTitleView.h"
#import "NotificationCell.h"
#import "GetNotificationsRequest.h"
#import "RemoveNotificationRequest.h"
#import "LoadProfileRequest.h"
#import "ChangePassVC.h"
#import "EditProfileRequest.h"



@interface ProfileVC ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;

@property (strong, nonatomic) NSDictionary* profile;

@property (strong, nonatomic) UIBarButtonItem *saveButton;

@end

@implementation ProfileVC


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(saveButtonPressed:)];
    
//
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Read all" style:UIBarButtonItemStylePlain target:self action:@selector(readAllAction)];
//
    __weak ProfileVC* wSelf = self;
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"PROFILE" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        [[LayoutManager shared] showHomeControllerAnimated:YES];
        [wSelf.navigationController popToRootViewControllerAnimated:YES];

    }];
    
    
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width / 2;
        
    _changePasswordButton.layer.cornerRadius = 5;
    
    if (_isEditable) {
        _changePasswordButton.hidden = NO;
    }else{
        _changePasswordButton.hidden = YES;
        _nameTextField.userInteractionEnabled = NO;
        _phoneTextField.userInteractionEnabled = NO;
        _addressTextField.userInteractionEnabled = NO;
        self.navigationController.navigationItem.rightBarButtonItem = nil;
    }
    
    if (_isMenu) {
        
        UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, 0, 40, 40);
        [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = anchorLeftButton;
    }else{
        
       self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"]
                                                                  landscapeImagePhone:nil
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self action:@selector(backAction:)];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadProfile];
}


- (void) anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setPersonImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.profileImageView  setImageWithURLRequest:request
                                 placeholderImage:[UIImage imageNamed:@"posted_user_ic@2x.png"]
                                     failureImage:nil
                                 progressViewSize:CGSizeMake(_profileImageView.bounds.size.width - 5, 4)
                                progressViewStile:UIProgressViewStyleDefault
                                progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                                   trackTintColor:nil
                                       sizePolicy:UNImageSizePolicyScaleAspectFill
                                      cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                          success:nil
                                          failure:nil
                                         progress:nil];
    
}


- (void)updateViews{
    
    _nameTextField.text = [_profile safeStringObjectForKey:@"name"];
    [self setPersonImageURLString:[_profile safeStringObjectForKey:@"avatar_url"]];
    
    NSString* phone = [_profile safeStringObjectForKey:@"phone_number"];
    _phoneTextField.text = phone;

    _addressTextField.text = [_profile safeStringObjectForKey:@"address"];
    
    [self updateSaveButton];
}

- (void)updateSaveButton{
    
    BOOL wasChanged = NO;
    
    if (![_nameTextField.text isEqualToString:[_profile safeStringObjectForKey:@"name"]]) {
        wasChanged = YES;
    }
    
    if (![_phoneTextField.text isEqualToString:[_profile safeStringObjectForKey:@"phone_number"]]) {
        wasChanged = YES;
    }
    
    if (![_addressTextField.text isEqualToString:[_profile safeStringObjectForKey:@"address"]]) {
        wasChanged = YES;
    }
    
    if (wasChanged) {
        [self.navigationItem setRightBarButtonItem:_saveButton animated:YES];
    }else{
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (void)loadProfile{
    
        LoadProfileRequest *loadProfileRequest = [[LoadProfileRequest alloc] init];
        loadProfileRequest.userId = [NSNumber numberWithInteger:[_userID integerValue]];
    
    [self showSpinnerWithName:@""];
        [[MMServiceProvider sharedProvider] sendRequest:loadProfileRequest success:^(LoadProfileRequest *request) {
            [self hideSpinnerWithName:@""];
            NSLog(@"Profile: %@", request.profile);
            
            _profile = request.profile;
            
            [self updateViews];
            
        } failure:^(LoadProfileRequest *request, NSError *error) {
            [self hideSpinnerWithName:@""];
            NSLog(@"Error: %@", error);
        }];
}

- (IBAction)changePasswordButtonClicked:(id)sender {
    [self hideKeyboard];
    
    [self updateSaveButton];
    
    ChangePassVC* vc = [ChangePassVC loadFromXIBForScrrenSizes];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)saveButtonPressed:(id)sender{
    [self hideKeyboard];
    [self saveProfile];
}

- (void)hideKeyboard{
    [_nameTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [_addressTextField resignFirstResponder];
    
    [self updateSaveButton];
}


- (void)saveProfile{
     //http://www.mainandme.com/api/v1/users/479?_token=HjSqKnLFNReDwy6ynWTQ&user%5Bname%5D=test1234
    NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/api/v1/users/%@?_token=%@&user[name]=%@&user[phone_number]=%@&user[address]=%@", [CommonManager shared].userId, [CommonManager shared].apiToken, _nameTextField.text, _phoneTextField.text, _addressTextField.text];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* r = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:30];
    r.HTTPMethod = @"PUT";
    
    
    [self showSpinnerWithName:@""];
    [NSURLConnection sendAsynchronousRequest:r
                                       queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               [self hideSpinnerWithName:@""];
                               [self loadProfile];
                           }];
    
//    EditProfileRequest *request = [EditProfileRequest new];
//    request.userId = [CommonManager shared].userId;
//    request.name = _nameTextField.text;
//    request.address = _addressTextField.text;
//    request.phone = _phoneTextField.text;
//    
//    [self showSpinnerWithName:@""];
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(EditProfileRequest *request) {
//        self.profile = request.profile;
//        [self hideSpinnerWithName:@""];
//        [self updateViews];
//    } failure:^(id _request, NSError *error) {
//       [self hideSpinnerWithName:@""];
//    }];
}

#pragma mark _______________________ Text Field Delegate Methods ________________________

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self updateSaveButton];
    return YES;
}

- (IBAction)textFieldChanged:(UITextField *)sender {
    
    [self updateSaveButton];
}


//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
//    return (newLength > 50) ? NO : YES;
//
//    return YES;
//}



#pragma mark _______________________ Notifications _________________________

- (void)keyboardWillShow:(NSNotification *)notification {
    //get the end position keyboard frame
    NSDictionary *keyInfo = [notification userInfo];
    CGRect keyboardFrame = [[keyInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
//    //convert it to the same view coords as the tableView it might be occluding
//    keyboardFrame = [self.quiltView convertRect:keyboardFrame fromView:nil];
//    //calculate if the rects intersect
//    CGRect intersect = CGRectIntersection(keyboardFrame, self.quiltView.bounds);
//    if (!CGRectIsNull(intersect)) {
//        //yes they do - adjust the insets on tableview to handle it
        //first get the duration of the keyboard appearance animation
        NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
        //change the table insets to match - animated to the same duration of the keyboard appearance
        [UIView animateWithDuration:duration animations:^{
            CGRect rc = self.view.frame;
            rc.origin.y = -100;
            self.view.frame = rc;
        }];

}

- (void) keyboardWillHide:  (NSNotification *) notification{
    NSDictionary *keyInfo = [notification userInfo];
    NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    //clear the table insets - animated to the same duration of the keyboard disappearance
    [UIView animateWithDuration:duration animations:^{
        CGRect rc = self.view.frame;
        rc.origin.y = 64;
        self.view.frame = rc;

    }];
}


@end
