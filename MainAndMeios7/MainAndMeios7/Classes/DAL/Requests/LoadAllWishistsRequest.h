//
//  LoadWishistRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"
#import "AuthenticatedRequest.h"

@interface LoadAllWishistsRequest : AuthenticatedRequest

//request
@property (strong, nonatomic) NSString *userId;

//response
@property (strong, nonatomic) NSArray *wishlist;

@end
