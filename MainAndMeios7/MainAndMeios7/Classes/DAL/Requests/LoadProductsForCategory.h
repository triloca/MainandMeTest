//
//  LoadProductsForCategory.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadProductsForCategory : ServiceRequest

//request
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *communityId;

//response
@property (strong, nonatomic) NSArray *products;

@end
