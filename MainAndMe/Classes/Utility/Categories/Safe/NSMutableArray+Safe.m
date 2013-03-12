//
//  NSMutableArray+Safe.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)

- (void)safeAddObject:(id)obj{
    if (obj != nil) {
        [self addObject:obj];
    }
}
@end
