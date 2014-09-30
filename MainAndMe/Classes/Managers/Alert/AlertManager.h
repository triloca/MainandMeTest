//
//  AlertManager.h
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

//!Example how to use
//!
//    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, UITextField *firstTextField, UITextField *secondTextField, NSInteger buttonIndex) {
//        if (alertView.cancelButtonIndex == buttonIndex) {
//            
//        }
//    }
//                                           title:@"Test Title"
//                                         message:@"Test Message"
//                                firstPlaceholder:@"Placeholder"
//                               secondPlaceholder:@"Scond placeholder"
//                                  alertViewStyle:UIAlertViewStyleLoginAndPasswordInput
//                               cancelButtonTitle:@"Cancel"
//                               otherButtonTitles:@"Other", nil];


@interface AlertManager : NSObject

@property (assign, nonatomic) BOOL isWrongCertificateAlertVisible;

+ (AlertManager*)shared;

//! Show alert with title only
- (void)showOkAlertWithTitle:(NSString*)title;

//! Show alert with title and message
- (void)showOkAlertWithTitle:(NSString*)title message:(NSString*)message;

//! Show alert with callback
- (void)showAlertWithCallBack:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))callBack
                        title:(NSString*)title
                      message:(NSString*)message
            cancelButtonTitle:(NSString*)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;


//! Old method
- (void)showTextFieldAlertWithCallBack:(void (^)(UIAlertView *alertView, UITextField* textField, NSInteger buttonIndex))callBack
                                 title:(NSString*)title
                               message:(NSString*)message
                           placeholder:(NSString*)placeholder
                                active:(BOOL)value
                     cancelButtonTitle:(NSString*)cancelButtonTitle
                     otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;


//! Show alert with textfields
//! Common method
- (UIAlertView*)showAlertWithCallBack:(void (^)(UIAlertView *alertView, UITextField* firstTextField, UITextField* secondTextField, NSInteger buttonIndex))callBack
                                title:(NSString*)title
                              message:(NSString*)message
                     firstPlaceholder:(NSString*)firstPlaceholder
                    secondPlaceholder:(NSString*)secondPlaceholder
                       alertViewStyle:(UIAlertViewStyle)alertViewStyle
                    cancelButtonTitle:(NSString*)cancelButtonTitle
                    otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;


@end