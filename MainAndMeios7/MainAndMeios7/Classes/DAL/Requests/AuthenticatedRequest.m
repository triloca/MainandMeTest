//
//  AuthenticatedRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AuthenticatedRequest.h"

@implementation AuthenticatedRequest

- (NSMutableDictionary *) userRequestDictionary {
    return [NSMutableDictionary new];
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *requestDict = [self userRequestDictionary];
    [requestDict safeSetObject:self.apiToken forKey:@"_token"];
    return requestDict;
}


- (RequestError *) validateResponse:(NSDictionary *)responseDictionary httpResponse:(NSHTTPURLResponse *)httpResponse {
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        NSString* message = [[[responseDictionary safeDictionaryObjectForKey:@"errors"] safeArrayObjectForKey:@"base"] safeObjectAtIndex:0];
        if (message.length > 0) {
            return [RequestError requestErrorWithCode:httpResponse.statusCode description:message];
        }
        
        if ([responseDictionary objectForKey:@"errors"]) {
            return [RequestError requestErrorWithCode:httpResponse.statusCode description:responseDictionary[@"errors"]];
        }
    }
    return nil;
}

@end
