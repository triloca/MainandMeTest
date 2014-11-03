//
//  LoginTrackerRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoginTrackerRequest.h"

@implementation LoginTrackerRequest

//- (NSString *) acceptableContentType {
//    return @"text/html";
//}

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"/login_trackers.json/%d", [_communityId intValue]];
}


@end
