//
//  NSString+Email.m
//  TennisBattle
//
//  Created by Sasha on 6/18/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//

#import "NSString+Email.h"

@implementation NSString (Email)

- (BOOL)isValidateEmail{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}


- (BOOL)isValidForRegex:(NSString*)regex{
    
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [regexTest evaluateWithObject:self];
}

@end
