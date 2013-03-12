//
//  NSArray+Common.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "NSArray+Common.h"


@implementation NSArray (Common)

- (BOOL) isValidIndex:(NSUInteger) index {
	return index < [self count];
}

- (NSArray*) filteredArrayUsingPredicateFormat:(NSString*) predicateFormat, ... {
	
	va_list list;
	va_start(list, predicateFormat);
	NSArray *filteredArray = [self filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateFormat arguments:list]];
	va_end(list);
	
	return filteredArray;
}

- (id) objectAtIndex:(NSUInteger)index orDefaultObject:(id) defObj {
	return ([self isValidIndex:index]) ? [self objectAtIndex:index] : defObj ;
}

- (id) objectWithKey:(NSString*) key equalTo:(id) value {
	for (id anObject in self) {
		if ( [[anObject valueForKey:key] isEqual:value] ) {
			return anObject;
		}
	}
	return nil;
}



- (id) firstObject{
	if ([self count]){
		return [self objectAtIndex:0];
	}
	else {
		return nil;
	}
}

+ (NSArray *)arrayWithRandomUnsignedIntegers:(NSUInteger)aCount{
    NSMutableArray * src = [NSMutableArray arrayWithCapacity:aCount];
    NSMutableArray * res = [NSMutableArray arrayWithCapacity:aCount];
    if (aCount){
        for (NSUInteger i = 0; i < aCount; i++) {
           [src addObject:[NSNumber numberWithUnsignedInt:i]];
        }
        for (NSUInteger i = 0; i < aCount; i++) {
            NSUInteger r = arc4random()%(aCount - i);
            [res addObject:[NSNumber numberWithUnsignedInt:[[src objectAtIndex:r] unsignedIntValue]]];
            [src removeObjectAtIndex:r];
        }
    }
    return [NSArray arrayWithArray:res];
}

- (id) randomObject{
    NSUInteger count = [self count];
    return count ? [self objectAtIndex:arc4random()%count] : nil;
}




@end
