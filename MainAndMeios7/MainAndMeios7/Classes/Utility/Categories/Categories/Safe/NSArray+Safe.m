//
//  NSArray+Safe.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "NSArray+Safe.h"

@implementation NSArray (Safe)

- (id)safeObjectAtIndex:(NSInteger)index{
    
    if ([self count] > index) {
       return [self objectAtIndex:index];
    }
    return nil;
}

- (id)safeObjectAtIndex:(NSInteger)index isKindOfClass:(__unsafe_unretained Class)classType{
  
  if ([self count] > index) {
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:classType]) {
      return obj;
    }
  }
  return nil;
}

- (id)safeDictionaryObjectAtIndex:(NSInteger)index{
    
    id obj = [self safeObjectAtIndex:index];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    }
    return [NSDictionary dictionary];
}

- (id)safeArrayObjectAtIndex:(NSInteger)index{
    
    id obj = [self safeObjectAtIndex:index];
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    return [NSArray array];
}

- (id)safeStringObjectAtIndex:(NSInteger)index{
    
    id obj = [self safeObjectAtIndex:index];
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    return @"";
}

- (id)safeNumberObjectAtIndex:(NSInteger)index{
    
    id obj = [self safeObjectAtIndex:index];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    return [NSNumber numberWithInt:-1];
}


+ (NSArray*)safeArrayWithArray:(NSArray*)array{
  if (array && [array isKindOfClass:[NSArray class]]) {
    return [NSArray arrayWithArray:(NSArray*)array];
  }
  return [NSArray array];
}


@end
