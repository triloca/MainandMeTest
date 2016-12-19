//
//  SlidingVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SlidingVC.h"
#import "RegistrationVC.h"
#import "ProductDetailsManager.h"
#import "IntroViewController.h"

@interface SlidingVC ()

@end

@implementation SlidingVC

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
    
}

#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //[self showLogin];
    
    
    //return;
    self.anchorRightRevealAmount = 242;
    
    if (![IntroViewController wasShown]) {
        IntroViewController* introVC = [IntroViewController loadFromXIBForScrrenSizes];
        [[LayoutManager shared].rootNVC  pushViewController:introVC animated:NO];
        
        introVC.didClickEndTutorial = ^(IntroViewController* obj){
            [IntroViewController setWasShown:YES];
            
            [self showLoginSuccess:^(LoginVC *loginVC, NSString *token) {
                [loginVC.navigationController dismissViewControllerAnimated:YES
                                                                 completion:^{}];
                [[LayoutManager shared] profileNVC];
                [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
                [[LayoutManager shared].profileVC view];
                
                [[LayoutManager shared].homeVC didLoginSuccessfuly];
                
            }
                   alreadyLoggedIn:^(LoginVC *loginVC, NSString *token) {
                       [[LayoutManager shared].rootNVC popViewControllerAnimated:NO];
                       [[LayoutManager shared].homeVC didLoginSuccessfuly];
                   }];
        };
        
        introVC.didClickSeeTowns = ^(IntroViewController* obj){
            
            //[[AlertManager shared] showOkAlertWithTitle:@"Please" message:@"Register first"];
            
            [self showLoginSuccess:^(LoginVC *loginVC, NSString *token) {
                [loginVC.navigationController dismissViewControllerAnimated:YES
                                                                 completion:^{}];
                [[LayoutManager shared] profileNVC];
                [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
                [[LayoutManager shared].profileVC view];
                
                [[LayoutManager shared].homeVC didLoginSuccessfuly];
                
            }
                   alreadyLoggedIn:^(LoginVC *loginVC, NSString *token) {
                       [[LayoutManager shared].rootNVC popViewControllerAnimated:NO];
                       [[LayoutManager shared].homeVC didLoginSuccessfuly];
                   }];

        };
        
        introVC.didClickAddItem = ^(IntroViewController* obj){
            [self showLoginSuccess:^(LoginVC *loginVC, NSString *token) {
                [loginVC.navigationController dismissViewControllerAnimated:YES
                                                                 completion:^{}];
                [[LayoutManager shared] profileNVC];
                [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
                [[LayoutManager shared].profileVC view];
                
                [[LayoutManager shared].homeVC didLoginSuccessfuly];
                
            }
                   alreadyLoggedIn:^(LoginVC *loginVC, NSString *token) {
                       [[LayoutManager shared].rootNVC popViewControllerAnimated:NO];
                       [[LayoutManager shared].homeVC didLoginSuccessfuly];
                   }];

        };
        
        introVC.didClickAddLocalBussines = ^(IntroViewController* obj){
            [self showLoginSuccess:^(LoginVC *loginVC, NSString *token) {
                [loginVC.navigationController dismissViewControllerAnimated:YES
                                                                 completion:^{}];
                [[LayoutManager shared] profileNVC];
                [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
                [[LayoutManager shared].profileVC view];
                
                [[LayoutManager shared].homeVC didLoginSuccessfuly];
                
            }
                   alreadyLoggedIn:^(LoginVC *loginVC, NSString *token) {
                       [[LayoutManager shared].rootNVC popViewControllerAnimated:NO];
                       [[LayoutManager shared].homeVC didLoginSuccessfuly];
                   }];

        };
        
        introVC.didClickWindshop = ^(IntroViewController* obj){
            [self showLoginSuccess:^(LoginVC *loginVC, NSString *token) {
                [loginVC.navigationController dismissViewControllerAnimated:YES
                                                                 completion:^{}];
                [[LayoutManager shared] profileNVC];
                [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
                [[LayoutManager shared].profileVC view];
                
                [[LayoutManager shared].homeVC didLoginSuccessfuly];
                
            }
                   alreadyLoggedIn:^(LoginVC *loginVC, NSString *token) {
                       [[LayoutManager shared].rootNVC popViewControllerAnimated:NO];
                       [[LayoutManager shared].homeVC didLoginSuccessfuly];
                   }];

        };
        
        introVC.didClickSeeBenefits = ^(IntroViewController* obj){
            [self showLoginSuccess:^(LoginVC *loginVC, NSString *token) {
                [loginVC.navigationController dismissViewControllerAnimated:YES
                                                                 completion:^{}];
                [[LayoutManager shared] profileNVC];
                [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
                [[LayoutManager shared].profileVC view];
                
                [[LayoutManager shared].homeVC didLoginSuccessfuly];
                
            }
                   alreadyLoggedIn:^(LoginVC *loginVC, NSString *token) {
                       [[LayoutManager shared].rootNVC popViewControllerAnimated:NO];
                       [[LayoutManager shared].homeVC didLoginSuccessfuly];
                   }];

        };

    }else{
        [self showLoginSuccess:^(LoginVC *loginVC, NSString *token) {
            [loginVC.navigationController dismissViewControllerAnimated:YES
                                                             completion:^{}];
            [[LayoutManager shared] profileNVC];
            [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
            [[LayoutManager shared].profileVC view];
            
            [[LayoutManager shared].homeVC didLoginSuccessfuly];
            
        }
               alreadyLoggedIn:^(LoginVC *loginVC, NSString *token) {
                   [[LayoutManager shared].rootNVC popViewControllerAnimated:NO];
                   [[LayoutManager shared].homeVC didLoginSuccessfuly];
               }];

    }
    
    
    return;
    
//    [self checkIsLoggedIn];
    
    
}

#pragma mark _______________________ Privat Methods(view)___________________
//! Update views by model
- (void)updateViews{
    
}

#pragma mark _______________________ Privat Methods ________________________

    - (void)showLoginSuccess:(void (^)(LoginVC* loginVC, NSString* token))success
             alreadyLoggedIn:(void (^)(LoginVC* loginVC, NSString* token))alreadyLoggedIn{
        
        [LoginVC loginVCPresentation:^(LoginVC *loginVC) {
            
            UINavigationController* loginNVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            
            [loginVC view];
            
            [[LayoutManager shared].rootNVC presentViewController:loginNVC
                                                         animated:YES
                                                       completion:^{
                                                           [[LayoutManager shared].rootNVC popViewControllerAnimated:NO];
                                                       }];
            
        }
                             success:^(LoginVC *loginVC, NSString *token) {
                                 success(loginVC, token);
                             }
                             failure:^(LoginVC *loginVC, NSError *error) {
                                 
                             }
                     alreadyLoggedIn:^(LoginVC *loginVC, NSString *token) {
                         alreadyLoggedIn(loginVC, token);
                     }];

    }
    
- (void)checkIsLoggedIn{
    
    if ([CommonManager shared].isLoggedIn) {
        [[LayoutManager shared] profileNVC];
        [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
        [[LayoutManager shared].profileVC view];
    }else{
        NSLog(@"Need registration");
        [self showRegistratioVC];
    }
    
 
}

- (void)showRegistratioVC{
    
    [RegistrationVC registrationVCPresentation:^(UIViewController *registrationVC) {
        UINavigationController* registrationNVC = [[UINavigationController alloc] initWithRootViewController:registrationVC];
        
        [registrationVC view];
        
        [[LayoutManager shared].rootNVC presentViewController:registrationNVC
                                                     animated:NO
                                                   completion:^{}];
        
        
    } success:^(UIViewController *registrationVC, NSString *token, NSDictionary* user) {
        
        [[LayoutManager shared] profileNVC];
        [LayoutManager shared].profileVC.userID = [CommonManager shared].userId;
        [[LayoutManager shared].profileVC view];
        
        [[LayoutManager shared].homeVC didLoginSuccessfuly];
                
        [registrationVC.navigationController dismissViewControllerAnimated:YES completion:^{}];
        
    } failure:^(UIViewController *registrationVC, NSError *error) {
        
    }];

}

#pragma mark _______________________ Buttons Action ________________________



#pragma mark _______________________ Delegates _____________________________



#pragma mark _______________________ Public Methods ________________________



#pragma mark _______________________ Notifications _________________________




@end
