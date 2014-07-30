//
//  AddCommentViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/16/13.
//
//

#import "AddCommentViewController.h"
#import "ProductDetailsManager.h"
#import "AlertManager.h"
#import "ReachabilityManager.h"
#import "LayoutManager.h"

@interface AddCommentViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;


@end

@implementation AddCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"Add Comment screen";

    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Comment";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_messageTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_messageTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [self setMessageTextView:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)postCommentButtonClicked:(id)sender {
    if (_messageTextView.text.length ==  0) {
        [[AlertManager shared] showOkAlertWithTitle:@"Enter Comment"];
    }
    [self postComment];
}
#pragma mark - TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    
}

- (void)textViewDidChange:(UITextView *)textView{
    
}

- (void)postComment{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    if (_isStoreState) {
        [self postStoreComment];
    }else{
        [self postProductComment];
    }
}

- (void)postProductComment{
    
    [self showSpinnerWithName:@"AddCommentViewController"];
    [ProductDetailsManager postProductComments:[[_productInfo safeNumberObjectForKey:@"id"] stringValue]
                                       comment:_messageTextView.text
                                       success:^{
                                           [self hideSpinnerWithName:@"AddCommentViewController"];
                                           [LayoutManager shared].mainViewController.isNeedRefresh = YES;
                                           [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               [self.navigationController popViewControllerAnimated:YES];
                                           }
                                                                                  title:@"Success"
                                                                                message:@"Comment posted successfully"
                                                                      cancelButtonTitle:@"Ok"
                                                                      otherButtonTitles:nil];
                                           
                                       }
                                       failure:^(NSError *error, NSString *errorString) {
                                           [self hideSpinnerWithName:@"AddCommentViewController"];
                                           [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                               message:errorString];
                                       }
                                     exception:^(NSString *exceptionString) {
                                         [self hideSpinnerWithName:@"AddCommentViewController"];
                                         [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                     }];
}

- (void)postStoreComment{
    
    [self showSpinnerWithName:@"AddCommentViewController"];
    [ProductDetailsManager postStoreComments:[[_productInfo safeNumberObjectForKey:@"id"] stringValue]
                                     comment:_messageTextView.text
                                     success:^{
                                         [self hideSpinnerWithName:@"AddCommentViewController"];
                                         [LayoutManager shared].mainViewController.isNeedRefresh = YES;
                                         [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                             [self.navigationController popViewControllerAnimated:YES];
                                         }
                                                                                title:@"Success"
                                                                              message:@"Comment posted successfully"
                                                                    cancelButtonTitle:@"Ok"
                                                                    otherButtonTitles:nil];
                                         
                                     }
                                     failure:^(NSError *error, NSString *errorString) {
                                         [self hideSpinnerWithName:@"AddCommentViewController"];
                                         [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                             message:errorString];
                                     }
                                   exception:^(NSString *exceptionString) {
                                       [self hideSpinnerWithName:@"AddCommentViewController"];
                                       [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                   }];
}

@end
