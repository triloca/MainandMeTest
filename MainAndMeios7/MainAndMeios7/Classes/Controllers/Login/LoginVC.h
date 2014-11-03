//
//  LoginVC.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/1/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//


@interface LoginVC : UIViewController
@property (copy, nonatomic) void (^successBlock)(LoginVC* loginVC, NSString* token);
@property (copy, nonatomic) void (^failureBlock)(LoginVC* loginVC, NSError* error);
@property (copy, nonatomic) void (^alreadyLoggedInBlock)(LoginVC* loginVC, NSString* token);


+ (void)loginVCPresentation:(void (^)(LoginVC* loginVC))presentation
                    success:(void (^)(LoginVC* loginVC, NSString* token))success
                    failure:(void (^)(LoginVC* loginVC, NSError* error))failure
            alreadyLoggedIn:(void (^)(LoginVC* loginVC, NSString* token))alreadyLoggedIn;

@end
