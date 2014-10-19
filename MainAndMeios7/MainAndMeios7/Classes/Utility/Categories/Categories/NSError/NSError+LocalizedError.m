//
//  NSError+LocalizedError.m
//  iC
//
//  Created by Alexander on 4/3/14.
//  Copyright (c) 2014 quadecco. All rights reserved.
//

#import "NSError+LocalizedError.h"

@implementation NSError (LocalizedError)

+ (NSError*)localizedErrorWithDomain:(NSString*)domain
                                code:(NSInteger)code
                      andDescription:(NSString*)description{
    
    NSMutableArray* objArray = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* keyArray = [NSMutableArray arrayWithCapacity:1];
    [objArray addObject:description];
    [keyArray addObject:NSLocalizedDescriptionKey];
    NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray
                                                      forKeys:keyArray];
    return [NSError errorWithDomain: domain
                               code: code
                           userInfo: eDict];
}

@end
