//
//  AddDeviceTokenRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AuthenticatedRequest.h"

@interface AddDeviceTokenRequest : AuthenticatedRequest


//request
@property (strong, nonatomic) NSString *deviceToken;

@end
