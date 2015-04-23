//
//  LoadProfile.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"
#import "AuthenticatedRequest.h"


@interface EditProfileRequest : AuthenticatedRequest

//request
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* address;

@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* confirmPassword;


//response
@property (strong, nonatomic) NSDictionary *profile;

@end
