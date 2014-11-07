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

@property (copy, nonatomic) void (^successBlock)(RegistrationVC* registrationVC, NSString* token);
@property (copy, nonatomic) void (^failureBlock)(RegistrationVC* registrationVC, NSError* error);
@property (copy, nonatomic) void (^alreadyLoggedInBlock)(RegistrationVC* registrationVC, NSString* token);


+ (void)registrationVCPresentation:(void (^)(RegistrationVC* registrationVC))presentation
                    success:(void (^)(RegistrationVC* registrationVC, NSString* token))success
                           failure:(void (^)(RegistrationVC* registrationVC, NSError* error))failure;


@end
