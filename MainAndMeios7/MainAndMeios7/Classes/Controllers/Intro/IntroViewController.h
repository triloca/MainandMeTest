//
//  IntroViewController.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController
    
    @property (copy, nonatomic) void (^didClickEndTutorial)(IntroViewController* obj);
    @property (copy, nonatomic) void (^didClickSeeTowns)(IntroViewController* obj);
    @property (copy, nonatomic) void (^didClickAddItem)(IntroViewController* obj);
    @property (copy, nonatomic) void (^didClickAddLocalBussines)(IntroViewController* obj);
    @property (copy, nonatomic) void (^didClickWindshop)(IntroViewController* obj);
    @property (copy, nonatomic) void (^didClickSeeBenefits)(IntroViewController* obj);

+ (BOOL)wasShown;
+ (void)setWasShown:(BOOL)value;
@end
