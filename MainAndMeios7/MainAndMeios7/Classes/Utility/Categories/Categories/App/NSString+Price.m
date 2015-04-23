//
//  NSString+Price.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 1/4/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "NSString+Price.h"

@implementation NSString (Price)

- (NSString*)priceString{
    if ([self isEqualToString:@"0.0"]) {
        return @"Call for price";
    }
    if ([self isEqualToString:@"25.0"]) {
        return @"$0 - $25";
    }
    if ([self isEqualToString:@"50.0"]) {
        return @"$25 - $50";
    }
    if ([self isEqualToString:@"100.0"]) {
        return @"$50 - $100";
    }
    if ([self isEqualToString:@"200.0"]) {
        return @"$100 - $200";
    }
    if ([self isEqualToString:@"500.0"]) {
        return @"$200 - $500";
    }
    if ([self isEqualToString:@"1000.0"]) {
        return @"$500 - $1000";
    }
    if ([self isEqualToString:@"10000.0"]) {
        return @"$1000 and up";
    }
       return nil;
}

@end
