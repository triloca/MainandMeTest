//
//  LoginRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 30.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoginRequest : ServiceRequest

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;

@end
