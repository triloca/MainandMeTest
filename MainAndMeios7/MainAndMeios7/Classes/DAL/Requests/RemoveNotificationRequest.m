//
//  RemoveNotificationRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RemoveNotificationRequest.h"

@implementation RemoveNotificationRequest

- (NSString *) method {
    return @"DELETE";
}

- (NSString *) path {
    return @"notifications/clear";
}

- (NSMutableDictionary *) userRequestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:_notificationId forKey:@"id"];
    return dict;
}

@end
