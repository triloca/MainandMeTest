//
//  NSMutableDictionary+Safe.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "NSMutableDictionary+Safe.h"

@implementation NSMutableDictionary (Safe)

- (void)safeSetObject:(id)obj forKey:(id<NSCopying>)key{
    if (obj != nil && key != nil) {
        [self setObject:obj forKey:key];
    }
}
@end
