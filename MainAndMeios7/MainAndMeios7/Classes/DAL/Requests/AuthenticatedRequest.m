//
//  AuthenticatedRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AuthenticatedRequest.h"

@implementation AuthenticatedRequest

- (id) init {
    if (self = [super init]) {
        self.apiToken = [CommonManager shared].apiToken;
    }
    return self;
}

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
            id error =responseDictionary[@"errors"];
            NSString *key = nil;
            if ([error isKindOfClass:[NSDictionary class]]) {
                key = [[error allKeys] lastObject];
                error = [error objectForKey:key];
            }
            
            if ([error isKindOfClass:[NSArray class]])
                error = [error lastObject];
            
            if ([key isValidate]) {
                error = [NSString stringWithFormat:@"%@ %@", key, [error description]];
            }

            return [RequestError requestErrorWithCode:httpResponse.statusCode description:error];
        }
    }
    return nil;
}

@end
