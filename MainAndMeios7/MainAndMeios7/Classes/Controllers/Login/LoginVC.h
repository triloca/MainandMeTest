//
//  LoginVC.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/1/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//


@interface LoginVC : UIViewController
@property (copy, nonatomic) void (^successBlock)(UIViewController* registrationVC, NSString* token);
@property (copy, nonatomic) void (^failureBlock)(UIViewController* registrationVC, NSError* error);
@property (copy, nonatomic) void (^alreadyLoggedInBlock)(UIViewController* registrationVC, NSString* token);



@end
