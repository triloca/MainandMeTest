//
//  LoginTrackerRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface LoginTrackerRequest : ServiceRequest

//request
@property (strong, nonatomic) NSString *communityId;


@end
