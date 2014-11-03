//
//  LikeProductRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LikeProductRequest.h"

@implementation LikeProductRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return [NSString stringWithFormat:@"products/%@/likes", _productId];
}

- (RequestError *) validateResponse:(NSDictionary *)responseDictionary httpResponse:(NSHTTPURLResponse *)httpResponse {
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        NSString* message = [responseDictionary safeStringObjectForKey:@"message"];
        if (message.length > 0) {
            return [RequestError requestErrorWithCode:httpResponse.statusCode description:message];
        }
    }
    return nil;
}

@end
