//
//  RegistrationRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 30.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface RegistrationRequest : ServiceRequest

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;


@property (strong, nonatomic) NSString *responseEmail;
@property (strong, nonatomic) NSString* api_token;

@end
