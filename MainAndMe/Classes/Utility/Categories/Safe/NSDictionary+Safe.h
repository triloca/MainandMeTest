//
//  NSDictionary+Safe.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSDictionary (Safe)
- (id)safeObjectForKey:(id)key;
- (id)safeStringObjectForKey:(id)key;
- (id)safeNumberObjectForKey:(id)key;
- (id)safeArrayObjectForKey:(id)key;
- (id)safeDictionaryObjectForKey:(id)key;
- (id)safeNSNumberObjectForKey:(id)key;
+ safeDictionaryWithObjectsAndKeysEndNSNull:(id)value, ...;
+ (NSDictionary*)safeDictionaryWithDictionary:(NSDictionary*)dictionary;
@end
