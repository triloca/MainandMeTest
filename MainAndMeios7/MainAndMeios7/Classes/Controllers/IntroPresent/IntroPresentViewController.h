//
//  IntroViewController.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroPresentViewController : UIViewController
@property (copy, nonatomic) void (^didClickEndTutorial)(IntroPresentViewController* obj);

@property (copy, nonatomic) void (^didClickReadGetStarted)(IntroPresentViewController* obj);
@property (copy, nonatomic) void (^didClickAddItem)(IntroPresentViewController* obj);
@property (copy, nonatomic) void (^didClickAddLocalBussines)(IntroPresentViewController* obj);
@property (copy, nonatomic) void (^didClickWindshop)(IntroPresentViewController* obj);
@property (copy, nonatomic) void (^didClickChat)(IntroPresentViewController* obj);

@end
