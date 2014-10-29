//
//  NSString+Validation.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 29.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

- (BOOL) isValidate {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0;
}


@end
