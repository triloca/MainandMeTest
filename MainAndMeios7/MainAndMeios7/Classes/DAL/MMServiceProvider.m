//
//  MMServiceProvider.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 29.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "MMServiceProvider.h"

NSString * const kServerBaseURL = @"http://www.mainandme.com";
NSString * const kServerAPIVersion = @"/api/v1";

@implementation MMServiceProvider

- (id) init {
    if (self =[super initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kServerBaseURL, kServerAPIVersion]]]) {
    }
    
    return self;
}
@end
