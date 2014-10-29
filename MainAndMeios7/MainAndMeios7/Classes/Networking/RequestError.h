//
//  RequestError.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 29.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRequestErrorDomain @"RequestErrorDomain"

@interface RequestError : NSError

+ (instancetype) requestErrorWithCode:(NSInteger) code description:(NSString *) description;

@end
