//
//  SaveCurrentUserRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AuthenticatedRequest.h"

@interface SaveCurrentUserRequest : AuthenticatedRequest

//request
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *birthday;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *phoneNumber;
@property BOOL emailCommunities;
@property BOOL emailStores;
@property BOOL emailPeople;
@property BOOL wishlist;

//response
@property (strong, nonatomic) NSDictionary *user;

@end
