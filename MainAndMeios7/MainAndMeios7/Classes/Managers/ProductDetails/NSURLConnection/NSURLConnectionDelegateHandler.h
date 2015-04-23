//
//  NSURLConnectionDelegateHandler.h
//  MainAndMe
//
//  Created by Sasha on 2/25/13.
//
//

#import <Foundation/Foundation.h>

@interface NSURLConnectionDelegateHandler : NSObject <NSURLConnectionDelegate>

@property (copy, nonatomic) void (^didReceiveResponseBlock)(NSURLConnection *connection, NSURLResponse*response);
@property (copy, nonatomic) void (^didReceiveDataBlock)(NSURLConnection *connection, NSData* data);

@property (copy, nonatomic) void (^didFailWithErrorBlock)(NSURLConnection *connection, NSError* error);
@property (copy, nonatomic) void (^didFinishLoadingBlock)(NSURLConnection *connection, id data);
@property (copy, nonatomic) void (^didThrowExceptionBlock)(NSURLConnection *connection, NSString* exceptionMessage);

+ (NSURLConnectionDelegateHandler*)handlerWithSuccess:(void (^)(NSURLConnection *connection, id data))success
                                              failure:(void (^)(NSURLConnection *connection, NSError* error))failure
                                             eception:(void (^)(NSURLConnection *connection, NSString* exceptionMessage))exception;
@end
