//
//  LoadWishlistDetailsRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.12.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadWishlistDetailsRequest : ServiceRequest

//request
@property (strong, nonatomic) NSString *wishlistId;

//response
@property (strong, nonatomic) NSArray *wishlist;


@end
