//
//  LoadProductsRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadProductsByStoreRequest : ServiceRequest

//request
@property (strong, nonatomic) NSNumber *storeId;
@property BOOL latest;

//response
@property (strong, nonatomic) NSArray *products;
@end
