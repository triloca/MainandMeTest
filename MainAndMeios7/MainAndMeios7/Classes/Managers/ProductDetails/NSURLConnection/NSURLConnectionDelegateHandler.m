//
//  NSURLConnectionDelegateHandler.m
//  MainAndMe
//
//  Created by Sasha on 2/25/13.
//
//

#import "NSURLConnectionDelegateHandler.h"

@interface NSURLConnectionDelegateHandler()
@property (strong, nonatomic) NSMutableData* connectionData;
@end


@implementation NSURLConnectionDelegateHandler 

+ (NSURLConnectionDelegateHandler*)handlerWithSuccess:(void (^)(NSURLConnection *connection, id data))success
                                              failure:(void (^)(NSURLConnection *connection, NSError* error))failure
                                             eception:(void (^)(NSURLConnection *connection, NSString* exceptionMessage))exception{

    NSURLConnectionDelegateHandler* handler = [[NSURLConnectionDelegateHandler alloc] init];
    handler.didFinishLoadingBlock = success;
    handler.didFailWithErrorBlock = failure;
    handler.didThrowExceptionBlock = exception;
    return handler;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.connectionData = [NSMutableData data];
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_connectionData setLength:0];
    if (_didReceiveResponseBlock) {
        _didReceiveResponseBlock(connection, response);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_connectionData appendData:data];
    if (_didReceiveDataBlock) {
        _didReceiveDataBlock(connection, data);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_didFailWithErrorBlock) {
        @try {
            _didFailWithErrorBlock(connection, error);
        }
        @catch (NSException *exception) {
            if (_didThrowExceptionBlock) {
                _didThrowExceptionBlock(connection, @"Exception, fail error");
            }
        }
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_didFinishLoadingBlock) {
        @try {
            _didFinishLoadingBlock(connection, _connectionData);
        }
        @catch (NSException *exception) {
            if (_didThrowExceptionBlock) {
                _didThrowExceptionBlock(connection, @"Exception, server API error");
            }
        }
    }
}

- (void)dealloc{
    NSLog(@"NSURLConnectionDelegateHandler DEALLOC++++++++++++++++++++++");
    self.didFailWithErrorBlock = nil;
    self.didFinishLoadingBlock = nil;
    self.didReceiveDataBlock = nil;
    self.didReceiveResponseBlock = nil;
    self.didThrowExceptionBlock = nil;
    
    self.connectionData = nil;
   
}

@end
