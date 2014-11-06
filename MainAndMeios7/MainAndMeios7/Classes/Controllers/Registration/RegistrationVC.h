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
    
    //! Please use property
    
    //!@property (strong, nonatomic) NSArray *arrPlaceholers;
    
    IBOutlet UITableView *tblView;
    IBOutlet UIButton *btnRegister;
    NSArray *arrPlaceholers;
    NSArray *arrKey;
    NSMutableDictionary *dictResult;
    UITextField *txtField;
}

@property (copy, nonatomic) void (^successBlock)(RegistrationVC* registrationVC, NSString* token);
@property (copy, nonatomic) void (^failureBlock)(RegistrationVC* registrationVC, NSError* error);
@property (copy, nonatomic) void (^alreadyLoggedInBlock)(RegistrationVC* registrationVC, NSString* token);


+ (void)registrationVCPresentation:(void (^)(RegistrationVC* registrationVC))presentation
                    success:(void (^)(RegistrationVC* registrationVC, NSString* token))success
                           failure:(void (^)(RegistrationVC* registrationVC, NSError* error))failure;

-(IBAction)btnRegister_Click:(id)sender;
-(IBAction)btnCancel_Click:(id)sender;

@end
