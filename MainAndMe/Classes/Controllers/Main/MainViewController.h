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
- (void)loadNearest;
@end
