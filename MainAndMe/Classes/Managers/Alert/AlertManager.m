//
//  AlertManager.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AlertManager.h"
#import "AlertDelegateHandler.h"
#import <objc/runtime.h>


static char kAlertHandlerObjectKey;


@interface AlertManager()
@property (assign, nonatomic) NSInteger alertsCount;
@end


@implementation AlertManager

#pragma mark - Shared Instance and Init
+ (AlertManager *)shared {
    
    static AlertManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
        _alertsCount = 0;
    }
    return self;
}

#pragma mark -

- (void)showOkAlertWithTitle:(NSString*)title{
    [self showAlertWithCallBack:nil
                          title:title
                        message:nil
              cancelButtonTitle:@"Ok"
              otherButtonTitles:nil];
}

- (void)showOkAlertWithTitle:(NSString*)title message:(NSString*)message{
    [self showAlertWithCallBack:nil
                          title:title
                        message:message
              cancelButtonTitle:@"Ok"
              otherButtonTitles:nil];
}

- (void)showAlertWithCallBack:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))callBack
                        title:(NSString*)title
                      message:(NSString*)message
            cancelButtonTitle:(NSString*)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION{
    
   AlertDelegateHandler* alertDelegateHandler =
    [AlertDelegateHandler alertDelegateHandlerWith:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (callBack){
            callBack(alertView, buttonIndex);
        }
    }];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:alertDelegateHandler
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:nil];
    
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
    {
        [alertView addButtonWithTitle:arg];
    }
    va_end(args);

    
    objc_setAssociatedObject(alertView, &kAlertHandlerObjectKey, alertDelegateHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alertView show];

}
@end
