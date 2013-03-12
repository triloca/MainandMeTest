//
//  NSMutableDictionary+Safe.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Safe)
- (void)safeSetObject:(id)obj forKey:(id<NSCopying>)key;
@end
