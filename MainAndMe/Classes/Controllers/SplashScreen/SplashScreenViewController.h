//
//  SplashScreenViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//
//

#import <UIKit/UIKit.h>

@interface SplashScreenViewController : UIViewController
@property (copy, nonatomic) void (^timeOutBlock)();
@end
