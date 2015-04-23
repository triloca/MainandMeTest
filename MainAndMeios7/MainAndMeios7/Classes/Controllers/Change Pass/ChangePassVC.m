//
//  ChangePassVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 11.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ChangePassVC.h"
#import "CustomTitleView.h"
#import "EditProfileRequest.h"

@interface ChangePassVC ()


@property (weak, nonatomic) IBOutlet UITextField *oldPassTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPassTextField;

@property (weak, nonatomic) IBOutlet UIButton *savePassButton;
@end

@implementation ChangePassVC

#pragma mark - Init


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"CHANGE PASSWORD" dropDownIndicator:NO clickCallback:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    _savePassButton.layer.cornerRadius = 5;


}

#pragma mark - Actions

- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Privat Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)saveProfile{
    //http://www.mainandme.com/api/v1/users/479?_token=HjSqKnLFNReDwy6ynWTQ&user%5Bname%5D=test1234
    NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/api/v1/users/%@?_token=%@&user[password]=%@&user[password_confirmation]=%@", [CommonManager shared].userId, [CommonManager shared].apiToken, _passTextField.text, _confirmNewPassTextField.text];
    
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
                               
                               if (connectionError == nil) {
                                
                                   [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }
                                                                          title:@"Password was changed"
                                                                        message:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                                   
                               }else{
                                   
                                   [[AlertManager shared] showOkAlertWithTitle:connectionError.localizedDescription];
                               }
                           }];
    
}


- (IBAction)savePassButtonClicked:(id)sender {
    if (_oldPassTextField.text.length == 0 || _passTextField.text.length == 0 || _confirmNewPassTextField.text.length == 0) {
        
        [[AlertManager shared] showOkAlertWithTitle:@"Enter passwords"];
        return;
    }
    
    if (![_passTextField.text isEqualToString:_confirmNewPassTextField.text]) {
        
        [[AlertManager shared] showOkAlertWithTitle:@"Password and confirm password not equal"];
        return;
    }
    [self saveProfile];
}

#pragma mark _______________________ Text Field Delegate Methods ________________________

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == _oldPassTextField) {
        [_passTextField becomeFirstResponder];
    }
    if (textField == _passTextField) {
        [_confirmNewPassTextField becomeFirstResponder];
    }
    if (textField == _confirmNewPassTextField) {
        [_confirmNewPassTextField resignFirstResponder];
    }
    
    return YES;
}

@end
