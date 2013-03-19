//
//  NSMutableArray+Safe.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)

- (id)safeObjectAtIndex:(NSInteger)index{
    
    if ([self count] > index) {
        return [self objectAtIndex:index];
    }
    return nil;
}

- (void)safeAddObject:(id)obj{
    if (obj != nil) {
        [self addObject:obj];
    }
}

- (void)safeReplaceObjectAtIndex:(NSInteger)index withObject:(id)obj{
    
    if ([self count] > index && obj) {
        [self replaceObjectAtIndex:index withObject:obj];
    }
}
@end
