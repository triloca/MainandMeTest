//
//  TwitterManager.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/21/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "TwitterManager.h"


@interface TwitterManager()

@end


@implementation TwitterManager
#pragma mark _______________________ Class Methods _________________________

#pragma mark - Shared Instance and Init
+ (TwitterManager *)shared {
    
    static TwitterManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

#pragma mark ____________________________ Init _____________________________

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
    }
    return self;
}

#pragma mark _______________________ Privat Methods ________________________



#pragma mark _______________________ Delegates _____________________________



#pragma mark _______________________ Public Methods ________________________



#pragma mark _______________________ Notifications _________________________



@end
