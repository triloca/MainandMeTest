//
//  UploadProductRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "UploadProductRequest.h"

@implementation UploadProductRequest

- (NSString *) method {
    return @"POST";
}

- (NSString *) path {
    return @"products";
}

- (NSDictionary *) requestDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict safeSetObject:_name forKey:@"product[name]"];
    [dict safeSetObject:_price forKey:@"product[price]"];
    [dict safeSetObject:_storeName forKey:@"product[store_name]"];
    [dict safeSetObject:_category forKey:@"product[category]"];
    [dict safeSetObject:_productDescription forKey:@"product[description]"];
    [dict safeSetObject:_apiToken forKey:@"token"];
    return dict;
}


- (NSString *) formFileField {
    return @"product[image]";
}

@end
