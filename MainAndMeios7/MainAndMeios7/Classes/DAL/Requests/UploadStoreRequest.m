//
//  UploadStoreRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 04.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "UploadStoreRequest.h"

@implementation UploadStoreRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return @"products";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:_name forKey:@"store[name]"];
    [dict safeSetObject:_street forKey:@"store[street]"];
    [dict safeSetObject:_city forKey:@"store[city]"];
    [dict safeSetObject:_state forKey:@"store[state]"];
    [dict safeSetObject:_zipCode forKey:@"store[postal_code]"];
    [dict safeSetObject:_country forKey:@"store[country]"];   
    [dict safeSetObject:_category forKey:@"store[category]"];
    [dict safeSetObject:_storeDescription forKey:@"store[description]"];
    [dict safeSetObject:_apiToken forKey:@"token"];
    return dict;
}

- (NSString *) formFileField {
    return @"store[image]";
}

@end
