//
//  ProfileVC.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 14.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileVC : UIViewController

@property (strong, nonatomic) NSString* userID;
@property (strong, nonatomic) NSDictionary* user;
@property (assign, nonatomic) BOOL isEditable;
@property (assign, nonatomic) BOOL isMenu;

@end
