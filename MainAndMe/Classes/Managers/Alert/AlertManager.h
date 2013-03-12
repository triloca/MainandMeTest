//
//  AlertManager.h
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface AlertManager : NSObject

+ (AlertManager*)shared;

- (void)showAlertWithCallBack:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))callBack
                        title:(NSString*)title
                      message:(NSString*)message
            cancelButtonTitle:(NSString*)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)showOkAlertWithTitle:(NSString*)title;
- (void)showOkAlertWithTitle:(NSString*)title message:(NSString*)message;
@end