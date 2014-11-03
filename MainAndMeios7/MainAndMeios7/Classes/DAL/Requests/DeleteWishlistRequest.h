//
//  DeleteWishlistRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface DeleteWishlistRequest : ServiceRequest


//request
@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSNumber *productId;

@end
