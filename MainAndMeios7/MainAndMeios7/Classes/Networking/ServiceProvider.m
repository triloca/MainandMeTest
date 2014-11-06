//
//  ServiceProvider.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 29.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceProvider.h"
#import "JSONRequestOperation.h"
#import "NSString+Email.h"
#import "NSString+Validation.h"
#import "NSDictionary+Safe.h"
//#import "NSString+SSToolkitAdditions.h"

@implementation ServiceProvider

#pragma mark singleton

+ (instancetype) sharedProvider {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark public

- (id) initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        self.parameterEncoding = AFJSONParameterEncoding;
        self.enableLogging = YES;
        [self registerOperationClasses];
    }
    return self;
}

- (NSMutableURLRequest *) requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = nil;
    
    if (!([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"])) {
        request = [super requestWithMethod:method path:path parameters:nil];
        
        NSURL *url = [self.baseURL URLByAppendingPathComponent:path]; //manually set params to the url
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];

        [request setURL:url];
        [request setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Content-Type"];
    } else {
        request = [super requestWithMethod:method path:path parameters:parameters];
        [request setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Content-Type"];
        

    }
    return request;
}

- (AFHTTPRequestOperation *) uploadFileWithRequest:(FileRequest *) fileRequest success:(RequestSuccessCallback) success failure:(RequestFailCallback) failure  {
    
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:fileRequest.path parameters:fileRequest.requestDictionary constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError *error = nil;
        if (fileRequest.filePath) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:fileRequest.filePath] name:[fileRequest formFileField] error:&error];
        } else if (fileRequest.fileData) {
            [formData appendPartWithFileData:fileRequest.fileData name:[fileRequest formFileField] fileName:fileRequest.fileName mimeType:@"application/octet-stream"];
        }
        if (error) {
            failure(fileRequest, error);
        }
    }];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request serviceRequest:fileRequest success:success failure:failure];
    
    [self enqueueHTTPRequestOperation:operation];
    
    return operation;
}

-  (AFHTTPRequestOperation *) HTTPRequestOperationWithRequest:(NSMutableURLRequest *) request serviceRequest:(ServiceRequest *) serviceRequest success:(RequestSuccessCallback) success failure:(RequestFailCallback) failure {
    
    if ([serviceRequest acceptableContentType])
        [request setValue:[serviceRequest acceptableContentType] forHTTPHeaderField:@"Accept"];
        
    [self log:@"request url:%@", request.URL];
    [self log:@"request headers:%@", request.allHTTPHeaderFields];
    if (request.HTTPBody.length > 0)
        [self log:@"request body: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:self.stringEncoding]];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self log:@"Response code: %d", operation.response.statusCode];
        [self log:@"Response headers: %@", operation.response.allHeaderFields];
        if (([operation.response.MIMEType hasPrefix:@"application"] || [operation.response.MIMEType hasPrefix:@"text"])) {
            [self log:@"Response body: %@", [[NSString alloc] initWithData:operation.responseData encoding:self.stringEncoding]];
        }
        
        RequestError *error = [serviceRequest validateResponse:responseObject httpResponse:operation.response];
        if (error) {
            [self log:@"request error:%@", error];
            if (failure)
                failure(serviceRequest, error);
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSObject *validResponseObject = responseObject;
                if ([_responseKey isValidate] && [validResponseObject isKindOfClass:[NSDictionary class]]) {
                    validResponseObject = [responseObject safeDictionaryObjectForKey:_responseKey];
                }
                [serviceRequest processResponse:validResponseObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success)
                        success(serviceRequest);
                });
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        serviceRequest.response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
        [self log:@"Response code: %d", operation.response.statusCode];
        [self log:@"Response headers: %@", operation.response.allHeaderFields];
        if ([operation.response.MIMEType hasPrefix:@"application"] || [operation.response.MIMEType hasPrefix:@"text"]) {
            [self log:@"Response body: %@", [[NSString alloc] initWithData:operation.responseData encoding:self.stringEncoding]];
        }
        [self log:@"request error: %@", error];
        
        NSError *requestError;
        if ([serviceRequest.response isKindOfClass:[NSDictionary class]])
            requestError = [serviceRequest validateResponse:(NSDictionary *) serviceRequest.response httpResponse:operation.response];
        
        if (failure)
            failure(serviceRequest, requestError ? requestError : error);
    }];
    
    return operation;
}

- (AFHTTPRequestOperation *) sendRequest:(ServiceRequest *) serviceRequest toPath:(NSString *) path success:(RequestSuccessCallback) success failure:(RequestFailCallback) failure {
    NSDictionary *requestDict = [serviceRequest requestDictionary];
    
    NSMutableURLRequest *request = [self requestWithMethod:[serviceRequest method] path:path parameters:requestDict];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request serviceRequest:serviceRequest success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
    return operation;
}

- (AFHTTPRequestOperation *) sendRequest:(ServiceRequest *) serviceRequest success:(RequestSuccessCallback) success failure:(RequestFailCallback) failure {
    return [self sendRequest:serviceRequest toPath:serviceRequest.path success:success failure:failure];
}

#pragma mark private

- (void) registerOperationClasses {
    [self registerHTTPOperationClass: [JSONRequestOperation class]];
}

- (void) log:(NSString *) logFormat, ... {
    if (self.enableLogging) {
        va_list argumentList;
        va_start(argumentList, logFormat);
        
        NSLogv(logFormat, argumentList);
        
        va_end(argumentList);
    }
}

#pragma mark -

@end
