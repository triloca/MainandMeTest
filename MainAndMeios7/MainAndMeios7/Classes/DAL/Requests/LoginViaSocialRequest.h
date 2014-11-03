//
//  LoginViaSocialRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoginViaSocialRequest : ServiceRequest


//request
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *credentialToken; //facebook access token | twitter auth token
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *type;


//response
@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) NSString *apiToken;

@end
