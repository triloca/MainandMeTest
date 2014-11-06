//
//  ServiceProvider.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 29.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ServiceRequest.h"
#import "FileRequest.h"

typedef void (^RequestSuccessCallback)(id request);
typedef void (^RequestFailCallback)(id request, NSError *requestError);

@interface ServiceProvider : AFHTTPClient

@property (nonatomic, copy) NSString *responseKey;
@property (nonatomic) BOOL enableLogging;

- (AFHTTPRequestOperation *) sendRequest:(ServiceRequest *) serviceRequest toPath:(NSString *) path success:(RequestSuccessCallback) success failure:(RequestFailCallback) failure;

- (AFHTTPRequestOperation *) sendRequest:(ServiceRequest *) serviceRequest success:(RequestSuccessCallback) success failure:(RequestFailCallback) failure;


+ (instancetype) sharedProvider;

//can be overrided in subclasses
- (void) registerOperationClasses;

@end
