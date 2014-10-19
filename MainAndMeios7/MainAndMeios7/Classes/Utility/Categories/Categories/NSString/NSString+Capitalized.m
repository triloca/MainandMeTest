//
//  NSString+Capitalized.m
//  TennisBattle
//
//  Created by Sasha on 6/26/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//

#import "NSString+Capitalized.h"

@implementation NSString (Capitalized)

- (NSString*)stringWithCapitalizedFirstCharacter{
    if ([self length] > 0){
        
        return [self stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                             withString:[[self substringToIndex:1] capitalizedString]];
    }
    else{
        return @"";
    }
}
@end
