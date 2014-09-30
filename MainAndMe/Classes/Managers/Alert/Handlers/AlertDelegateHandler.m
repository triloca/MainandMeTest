//
//  AlertDelegateHandler.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//
//

#import "AlertDelegateHandler.h"

@interface AlertDelegateHandler ()

@end

@implementation AlertDelegateHandler

#pragma mark - AlertView Delegate
+ (AlertDelegateHandler*)alertDelegateHandlerWith:(void (^)(UIAlertView* alertView, NSInteger buttonIndex))didClickedButtonBlock{
    AlertDelegateHandler* alertDelegateHandler = [AlertDelegateHandler new];
    alertDelegateHandler.didClickedButtonBlock = didClickedButtonBlock;
    return alertDelegateHandler;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_didClickedButtonBlock) {
        _didClickedButtonBlock(alertView, buttonIndex);
    }
}

- (void)dealloc
{
    NSLog(@"!!!! DEALLOC ALERT HANDLER");
    _didClickedButtonBlock = nil;
}
@end
