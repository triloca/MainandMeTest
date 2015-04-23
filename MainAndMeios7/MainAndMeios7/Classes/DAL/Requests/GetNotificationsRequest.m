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

- (void) processResponse:(NSArray *)response {
    if ([response isKindOfClass:[NSArray class]]) {
        
        NSMutableArray* temp = [NSMutableArray arrayWithArray:response];
        for (id obj in response) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([[obj safeNumberObjectForKey:@"read"] intValue] == 1) {
                    [temp removeObject:obj];
                }
            }
        }
        
        self.notifications = [NSArray arrayWithArray:temp];

        
        self.allNotifications = (NSArray *) response;
    }
}

@end
