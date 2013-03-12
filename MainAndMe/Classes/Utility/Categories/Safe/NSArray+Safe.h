//
//  NSArray+Safe.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSArray (Safe)
- (id)safeObjectAtIndex:(NSInteger)index;
- (id)safeDictionaryObjectAtIndex:(NSInteger)index;
+ (NSArray*)safeArrayWithArray:(NSArray*)array;
- (id)safeObjectAtIndex:(NSInteger)index isKindOfClass:(__unsafe_unretained Class)classType;
@end
