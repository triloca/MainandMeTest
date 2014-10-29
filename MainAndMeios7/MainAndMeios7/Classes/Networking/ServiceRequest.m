//
//  ServiceRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 29.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"
#import "NSDictionary+Safe.h"

@implementation ServiceRequest

- (NSString *) acceptableContentType {
    return @"application/json";
}

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return @"(request_path_here)";
}

- (NSDictionary *) requestDictionary {
    return [NSDictionary dictionary];
}

- (void) processResponse: (NSObject *) response {
    self.response = response;
}

- (RequestError *) validateResponse:(NSDictionary*) responseDictionary httpResponse:(NSHTTPURLResponse *) httpResponse {
    if (httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 202) {
        self.response = responseDictionary;
        return [RequestError requestErrorWithCode:httpResponse.statusCode description:@"Some server error occured."];
    }
    
    return nil;
}
@end
