//
//  SearchRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 02.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AllStoresRequest.h"

@implementation AllStoresRequest

- (id) initWithCommunity:(NSString*)community_id{
    if (self = [super init]) {
        self.page = 1;
        self.perPage = kPerPagePropertyValue;
        self.community_id = community_id;
    }
    return self;
}

//- (NSString *) acceptableContentType {
//    return @"text/html";
//}

- (NSString *) method {
    return @"GET";
}

- (NSString *) path {
 return @"/stores/latest";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    
    [dict safeSetObject:@(_page) forKey:@"page"];
    [dict safeSetObject:@(_perPage) forKey:@"per_page"];
    [dict safeSetObject:_community_id forKey:@"community_id"];
    
    [dict safeSetObject:[CommonManager shared].apiToken forKey:@"_token"];
    
    return dict;
}

- (void) processResponse:(NSArray *)response {
    
   // NSLog(@"Response: %@", response);
    
    if ([response isKindOfClass:[NSArray class]]) {
        self.objects = response;
    }
    
}

@end
