//
//  RequestError.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 29.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RequestError.h"


@implementation RequestError

+ (instancetype) requestErrorWithCode:(NSInteger) code description:(NSString *) description {
    return [RequestError errorWithDomain:kRequestErrorDomain code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil]];
}

@end
