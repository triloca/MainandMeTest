//
//  MainViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
@property (assign, nonatomic) BOOL isNeedRefresh;
@property (assign, nonatomic) BOOL isNeedSendToken;
@property (assign, nonatomic) BOOL isJustExplore;
- (void)loadNearest;
- (void)refreshCurrentList:(id)refreshCurrentList;
- (void)loadNotifications;
@end
