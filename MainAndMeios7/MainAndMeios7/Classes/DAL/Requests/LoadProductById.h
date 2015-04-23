//
//  LoadProductById.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadProductById : ServiceRequest

//request
@property (strong, nonatomic) NSNumber *productId;

//response
@property (strong, nonatomic) NSDictionary *product;

- (id) initWithProductId: (NSNumber *) productId;

@end
