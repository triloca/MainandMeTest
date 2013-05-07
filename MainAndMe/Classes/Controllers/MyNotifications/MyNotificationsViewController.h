//
//  SearchDetailsViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//
//

#import <UIKit/UIKit.h>

@interface MyNotificationsViewController : UIViewController
@property (assign, nonatomic) BOOL isNeedRefresh;
@property (strong, nonatomic) NSDictionary* categoryInfo;
@property (assign, nonatomic) BOOL isAllState;
@end
