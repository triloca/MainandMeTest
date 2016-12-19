//
//  YourGPSCityViewController.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/26/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YourGPSCityViewController : UIViewController

@property (copy, nonatomic) void (^didClickStartBrowsing)(YourGPSCityViewController* obj);
@property (copy, nonatomic) void (^didClickEditCity)(YourGPSCityViewController* obj);
@property (copy, nonatomic) void (^didClickWindowShop)(YourGPSCityViewController* obj);
@property (copy, nonatomic) void (^didClickBenefits)(YourGPSCityViewController* obj);

@end
