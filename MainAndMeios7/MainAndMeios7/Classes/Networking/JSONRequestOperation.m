//
//  JSONRequestOperation.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 29.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "JSONRequestOperation.h"

@interface JSONRequestOperation ()

@property (nonatomic, strong) NSError *contentTypeError;

@end

@implementation JSONRequestOperation

#pragma mark - AFHTTPRequestOperation

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [super performSelector:@selector(setResponse:) withObject:response];
#pragma clang diagnostic pop
        if ([self hasAcceptableContentType]) {
            [super connection:connection didReceiveResponse:response];
        } else {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[NSString stringWithFormat:NSLocalizedString(@"Expected content type %@, got %@", nil), [[self class] acceptableContentTypes], [self.response MIMEType]] forKey:NSLocalizedDescriptionKey];
            self.contentTypeError = [[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
            [connection cancel];
            [super connectionDidFinishLoading:connection];
        }
    }
}

- (NSError *) error {
    if (self.contentTypeError)
        return self.contentTypeError;
    else
        return [super error];
}

@end
