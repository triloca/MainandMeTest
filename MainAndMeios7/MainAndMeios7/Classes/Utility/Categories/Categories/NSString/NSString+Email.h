//
//  NSString+Email.h
//  TennisBattle
//
//  Created by Sasha on 6/18/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Email)

- (BOOL)isValidateEmail;
- (BOOL)isValidForRegex:(NSString*)regex;

@end
