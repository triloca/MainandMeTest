//
//  RateStoreRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AuthenticatedRequest.h"

@interface RateStoreRequest : AuthenticatedRequest

//request
@property (strong, nonatomic) NSString *storeId;
@property NSInteger rate;

@end
