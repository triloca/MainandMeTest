//
//  LoadProductsRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LoadSalesEventsRequest.h"

@implementation LoadSalesEventsRequest

//- (NSString *) acceptableContentType {
//    return @"text/html";
//}

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
    
    //http://mainandme.com/api/v1/communities/:community_id/events
    return [NSString stringWithFormat:@"communities/%@/events", self.communityId];
}

- (void) processResponse:(NSObject *)response {
    if ([response isKindOfClass:[NSArray class]]) { 
        self.events = (NSArray *) response;
    }
}
@end
