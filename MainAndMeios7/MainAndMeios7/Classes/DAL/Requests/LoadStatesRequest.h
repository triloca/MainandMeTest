//
//  LoadStatesRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoadStatesRequest : ServiceRequest

//response
@property (strong, nonatomic) NSDictionary *states;

@end
