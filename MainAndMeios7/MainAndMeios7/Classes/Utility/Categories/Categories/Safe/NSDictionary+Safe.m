//
//  NSDictionary+Safe.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "NSDictionary+Safe.h"

@implementation NSDictionary (Safe)

- (id)safeObjectForKey:(id)key{
    if (key == nil) {
        return nil;
    }
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return obj;
}

- (id)safeStringObjectForKey:(id)key{
    
    id obj = [self safeObjectForKey:key];
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    return @"";
}

- (id)safeNumberObjectForKey:(id)key{
    
    id obj = [self safeObjectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    return [[NSNumber alloc] init];
}

- (id)safeArrayObjectForKey:(id)key{
    
    id obj = [self safeObjectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    return [NSArray array];
}
- (id)safeDictionaryObjectForKey:(id)key{
    
    id obj = [self safeObjectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    }
    return [NSDictionary dictionary];
}

- (id)safeNSNumberObjectForKey:(id)key{
    
    id obj = [self safeObjectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    return [NSNumber numberWithBool:NO];
}

+ safeDictionaryWithObjectsAndKeysEndNSNull:(id)value, ... {
    va_list  arguments;
    
    va_start(arguments, value);
    
    NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
    
    id obj = value;
    id key = nil;
    
    while(1){
        key = va_arg(arguments, id);
        if ([key isKindOfClass:[NSNull class]]) {
            break;
        }
        if (key && obj) {
            [tempDict setObject:obj forKey:key];
        }
        
        obj = va_arg(arguments, id);
        if ([obj isKindOfClass:[NSNull class]]) {
            break;
        }
    }
    
    va_end(arguments);

    return [NSDictionary dictionaryWithDictionary:tempDict];
}

+ (NSDictionary*)safeDictionaryWithDictionary:(NSDictionary*)dictionary{
  
  if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
    return [NSDictionary dictionaryWithDictionary:dictionary];
  }
  return [NSDictionary dictionary];
}
@end
