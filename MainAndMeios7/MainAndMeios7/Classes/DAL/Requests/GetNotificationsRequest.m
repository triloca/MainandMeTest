//
//  GetNotificationsRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "GetNotificationsRequest.h"

@implementation GetNotificationsRequest


- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return @"notifications";
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        self.notifications = (NSArray *) response;
    }
}

@end
