//
//  NSData+String.h
//  TennisBattle
//
//  Created by Sasha on 10/20/13.
//  Copyright (c) 2013 uniprog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (String)

- (NSString*)howLongAgoString;
- (NSDate*)yearsAgo:(NSInteger)years;
- (NSInteger)age;

@end
