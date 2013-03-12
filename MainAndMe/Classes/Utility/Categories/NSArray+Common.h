//
//  NSArray+Common.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NSArray (Common) 

- (BOOL) isValidIndex:(NSUInteger) index;
- (NSArray*) filteredArrayUsingPredicateFormat:(NSString*) predicateFormat, ...;
- (id)objectAtIndex:(NSUInteger)index orDefaultObject:(id) defObj;
- (id)objectWithKey:(NSString*) key equalTo:(id) value;
- (id) firstObject;
- (id) randomObject;

+ (NSArray *)arrayWithRandomUnsignedIntegers:(NSUInteger)aCount;

@end
