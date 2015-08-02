//
//  RegistrationVC.h
//  MainAndMeios7
//
//  Created by Bhumi Shah on 03/11/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistrationVC : UIViewController <UITextFieldDelegate>
{
    
      
   
}

@property (copy, nonatomic) void (^successBlock)(UIViewController* registrationVC, NSString* token, NSDictionary* user);
@property (copy, nonatomic) void (^failureBlock)(UIViewController* registrationVC, NSError* error);
@property (copy, nonatomic) void (^alreadyLoggedInBlock)(UIViewController* registrationVC, NSString* token);


+ (void)registrationVCPresentation:(void (^)(UIViewController* registrationVC))presentation
                           success:(void (^)(UIViewController* registrationVC, NSString* token, NSDictionary* user))success
                           failure:(void (^)(UIViewController* registrationVC, NSError* error))failure;


@end
