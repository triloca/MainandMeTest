//
//  LoadProductsRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadSalesEventsRequest : ServiceRequest

//request
@property (strong, nonatomic) NSString *communityId;

//response
@property (strong, nonatomic) NSArray *events;
@end
