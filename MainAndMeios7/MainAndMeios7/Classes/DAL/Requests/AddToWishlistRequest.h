//
//  AddToWishlistRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 12.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthenticatedRequest.h"

@interface AddToWishlistRequest : AuthenticatedRequest

//request
@property (strong, nonatomic) NSNumber *productId;
@property (strong, nonatomic) NSNumber *wishlistId;

@end
