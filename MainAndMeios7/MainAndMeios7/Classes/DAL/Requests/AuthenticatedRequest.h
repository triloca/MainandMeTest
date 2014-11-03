//
//  AuthenticatedRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface AuthenticatedRequest : ServiceRequest

@property (strong, nonatomic) NSString *apiToken;

//to override in subclasses:
- (NSMutableDictionary *) userRequestDictionary;

@end
