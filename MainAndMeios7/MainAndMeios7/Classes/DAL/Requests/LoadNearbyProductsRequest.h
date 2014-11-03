//
//  LoadNearbyProducts.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"
#import <CoreLocation/CoreLocation.h>
@interface LoadNearbyProductsRequest : ServiceRequest

//request
@property CLLocationCoordinate2D coordinate;

//response
@property (strong, nonatomic) NSArray *products;

@end
