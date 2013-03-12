//
//  AlertDelegateHandler.h
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//
//

#import <Foundation/Foundation.h>

@interface AlertDelegateHandler : NSObject <UIAlertViewDelegate>
+ (AlertDelegateHandler*)alertDelegateHandlerWith:(void (^)(UIAlertView* alertView, NSInteger buttonIndex))didClickedButtonBlock;
@end
