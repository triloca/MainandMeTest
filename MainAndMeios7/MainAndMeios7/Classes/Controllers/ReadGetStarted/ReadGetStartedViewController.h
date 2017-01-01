//
//  ReadGetStartedViewController.h
//  MainAndMeios7
//
//  Created by Alexanedr on 12/7/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadGetStartedViewController : UIViewController
@property (copy, nonatomic) void (^didClickHomeButton)(ReadGetStartedViewController* sender);
@property (copy, nonatomic) void (^didClickPhotoButton)(ReadGetStartedViewController* sender);
@end
