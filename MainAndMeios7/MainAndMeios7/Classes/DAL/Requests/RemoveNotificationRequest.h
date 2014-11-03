//
//  RemoveNotificationRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AuthenticatedRequest.h"

@interface RemoveNotificationRequest : AuthenticatedRequest


//request
@property (strong, nonatomic) NSNumber *notificationId;

@end
