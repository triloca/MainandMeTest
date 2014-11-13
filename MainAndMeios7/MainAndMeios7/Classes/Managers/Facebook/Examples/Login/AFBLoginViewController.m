//
//  AFBLoginViewController.m
//  AllComponents
//
//  Created by Sasha on 4/26/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//

#import <FacebookSDK/FBSession.h>
#import "AFBLoginViewController.h"
#import "FacebookManager.h"
#import "AlertManager.h"
#import "AFBFriendsViewController.h"
#import <FacebookSDK/FBGraphUser.h>

@interface AFBLoginViewController()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fbIdLabel;

@end


@implementation AFBLoginViewController

#pragma mark _______________________ Class Methods _________________________



#pragma mark ____________________________ Init _____________________________

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization

    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateViews];
}
#pragma mark _______________________ Privat Methods(view)___________________
//! Update views by model
- (void)updateViews{
    if ([FacebookManager shared].user) {
        _nameLabel.text = [[FacebookManager shared].user name];
        _fbIdLabel.text = [[FacebookManager shared].user id];
        
    [self setupAvatarURLString:
     [[FacebookManager shared] userAvatarURL:_fbIdLabel.text
                                                                      type:@"large"]];
        
        _friendsButton.enabled = YES;
        
    }else{
        _nameLabel.text = @"";
        _fbIdLabel.text = @"";
        
        [self setupAvatarURLString:@""];
        
        _friendsButton.enabled = NO;
    }
}

#pragma mark _______________________ Privat Methods ________________________

- (void)loginToFacebook{
    
    [[FacebookManager shared] loginWithReadPermissions:nil
                                          allowLoginUI:YES
                                               success:^(FBSession *session, FBSessionState status) {
                                                   
                                                   [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                       [self loadMeFacebook];
                                                   }
                                                                                          title:@"Logged in with success"
                                                                                        message:nil
                                                                              cancelButtonTitle:@"OK"
                                                                              otherButtonTitles:nil];
                                                   
                                               }
                                               failure:^(FBSession *session, FBSessionState status, NSError *error) {
                                                   
                                               }
                                         olreadyLogged:^(FBSession *session, FBSessionState status) {
                                             
                                         }];
}


- (void)loadMeFacebook{
    [self showSpinnerWithName:@"Load Me"];
    
    [[FacebookManager shared] loadMeWithSuccess:^(id<FBGraphUser> user) {
        [self hideSpinnerWithName:@"Load Me"];
        
        [FacebookManager shared].user = user;
    
        [self updateViews];
    }
                                        failure:^(FBRequestConnection *connection, id result, NSError *error) {
                                            [self hideSpinnerWithName:@"Load Me"];
                                            
                                            [self updateViews];
                                        }];

}


- (void)setupAvatarURLString:(NSString*)urlString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [_avatarImageView setImageWithURLRequest:request
                            placeholderImage:nil
                                failureImage:nil
                            progressViewSize:CGSizeZero
                           progressViewStile:UIProgressViewStyleDefault
                           progressTintColor:nil
                              trackTintColor:nil
                                  sizePolicy:UNImageSizePolicyScaleAspectFill
                                 cachePolicy:UNImageCachePolicyIgnoreCache
                                     success:nil
                                     failure:nil
                                    progress:nil];
}

#pragma mark _______________________ Buttons Action ________________________

- (IBAction)loginButtonClicked:(UIButton *)sender {
    if (FBSession.activeSession.isOpen){
        [[AlertManager shared] showOkAlertWithTitle:@"Already logged in"];
    }else{
        [self loginToFacebook];
    }
}

- (IBAction)logoutButtonClicked:(UIButton *)sender {
    [[FacebookManager shared] logOut];
    [self updateViews];
}

- (IBAction)friendsButtonClicked:(id)sender {
    
    UIStoryboard *aFBLoginStoryboard = [UIStoryboard storyboardWithName:@"AFBLogin" bundle:nil];
    
    AFBFriendsViewController* aFBFriendsViewController = [aFBLoginStoryboard instantiateViewControllerWithIdentifier:@"AFBFriendsViewController"];
    
    [self.navigationController pushViewController:aFBFriendsViewController
                                         animated:YES];

}
#pragma mark _______________________ Delegates _____________________________



#pragma mark _______________________ Public Methods ________________________



#pragma mark _______________________ Notifications _________________________



@end
