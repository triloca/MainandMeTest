//
//  LoadProductsByKeywordsRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadProductsRequest : ServiceRequest

//request
@property (strong, nonatomic) NSString *communityId;
//optional
@property (strong, nonatomic) NSString *keywords;

@property NSUInteger perPage;


//response
@property (strong, nonatomic) NSArray *products;

@end
