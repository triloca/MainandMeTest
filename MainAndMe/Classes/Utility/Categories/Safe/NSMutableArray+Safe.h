//
//  NSMutableArray+Safe.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSMutableArray (Safe)
- (id)safeObjectAtIndex:(NSInteger)index;
- (void)safeAddObject:(id)obj;
- (void)safeReplaceObjectAtIndex:(NSInteger)index withObject:(id)obj;

@end
