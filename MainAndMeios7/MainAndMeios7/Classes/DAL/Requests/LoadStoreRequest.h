//
//  LoadStore.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadStoreRequest : ServiceRequest

//request
@property (strong, nonatomic) NSNumber *storeId;


//response
@property (strong, nonatomic) NSDictionary *storeDetails;
@end
