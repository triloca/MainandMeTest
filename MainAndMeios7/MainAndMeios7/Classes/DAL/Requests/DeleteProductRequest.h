//
//  DeleteProductRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface DeleteProductRequest : ServiceRequest

//request
@property (strong, nonatomic) NSNumber *productId;
@property (strong, nonatomic) NSNumber *wishlistId;

@end
